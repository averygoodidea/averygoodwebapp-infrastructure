#!/bin/bash
ENVIRONMENT=$1
TEMPLATE=./cloudformation/environment.yaml
export $(grep -v '^#' .env | xargs)
[[ $ENVIRONMENT != prod ]] && SUBDOMAIN="$ENVIRONMENT". || SUBDOMAIN=""

if [ $ENVIRONMENT != 'global' ] && [ $ENVIRONMENT != 'prod' ] && [ $ENVIRONMENT != 'dev' ] && [ $ENVIRONMENT != 'avery' ]; then
    echo "Environment $ENVIRONMENT is not valid"
    exit 1
elif [ ! -f $TEMPLATE ]; then
    echo "file $TEMPLATE does not exist"
    exit 1
else
  AWS_PROFILE=$2
  BUCKET_PREFIX=$(sed -e "s,\.,-," <<<$DOMAIN_NAME)
  PROJECT="$BUCKET_PREFIX"-"$ENVIRONMENT"-stack
  DEPLOYMENT_BUCKET=$PROJECT
  DOMAIN_NAME_REDIRECT="${SUBDOMAIN}www.${DOMAIN_NAME}"
  FQDN=${SUBDOMAIN}$DOMAIN_NAME

  # make a build directory to store cloudformation artifacts
  rm -rf build
  mkdir build

  # Global
  # - fragments for account-wide exported output value names
  NAMESPACE=$(sed -e "s,\.,-," <<< $DOMAIN_NAME)
  GLOBAL_TLS_CERTIFICATE_ARN_FRAGMENT="global-${NAMESPACE}-TLSCertificateArn"
  GLOBAL_HOSTEDZONE_FRAGMENT="global-${NAMESPACE}-HostedZoneId"

  if [ $ENVIRONMENT = 'global' ] ; then
    echo "------------------"
    echo "Step 1 of 2 (AWS Route 53)"
    echo "Copy the DNS Addresses from the ${DOMAIN_NAME} Hosted Zone here:"
    echo "https://console.aws.amazon.com/route53/home?region=us-east-1"
    echo "into your domain registrar's DNS records."
    echo "------------------"
    echo "Step 2 of 2 (AWS Certificate Manager)"
    echo "Click '$DOMAIN_NAME' > 'Create Record in Route 53' for each pending validation here:"
    echo "https://console.aws.amazon.com/acm/home?region=us-east-1#/"
    echo "------------------"
    # affix url pattern to exported values
    cp ./cloudformation/global.yaml ./cloudformation/global.template.yaml
    sed -i '' -e "s%<GlobalTLSCertificateArn>%$GLOBAL_TLS_CERTIFICATE_ARN_FRAGMENT%" ./cloudformation/global.template.yaml
    sed -i '' -e "s%<GlobalHostedZoneId>%$GLOBAL_HOSTEDZONE_FRAGMENT%" ./cloudformation/global.template.yaml
    GLOBAL_TEMPLATE=./cloudformation/global.template.yaml
    GLOBAL_STACK="$BUCKET_PREFIX"-global-stack
    # generate next stage yaml file
    aws cloudformation package                                \
        --template-file $GLOBAL_TEMPLATE                      \
        --output-template-file build/output.yaml              \
        --s3-bucket $DEPLOYMENT_BUCKET                        \
        --profile $AWS_PROFILE

    # the actual deployment step
    aws cloudformation deploy                                 \
        --template-file build/output.yaml                     \
        --stack-name $GLOBAL_STACK                            \
        --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND  \
        --profile $AWS_PROFILE                                \
        --parameter-overrides DomainName=$DOMAIN_NAME Environment=$ENVIRONMENT
  else
    # make the deployment bucket in case it doesn't exist
    aws s3 rb s3://$DEPLOYMENT_BUCKET --force --profile $AWS_PROFILE
    aws s3 mb s3://$DEPLOYMENT_BUCKET --profile $AWS_PROFILE

    # Environment
    cp ./cloudformation/environment.yaml ./cloudformation/environment.template.yaml
    # - replace <EnvironmentNamespace> with fragment
    ENVIRONMENT_NAMESPACE=$NAMESPACE-$ENVIRONMENT
    sed -i '' -e "s%<EnvironmentNamespace>%$ENVIRONMENT_NAMESPACE%" ./cloudformation/environment.template.yaml
    # - replace <Namespace> with fragment
    sed -i '' -e "s%<Namespace>%$NAMESPACE%" ./cloudformation/environment.template.yaml
    TEMPLATE=./cloudformation/environment.template.yaml

    # FireRecordStack
    cp ./cloudformation/firerecord.yaml ./cloudformation/firerecord.template.yaml
    # - replace <GlobalHostedZoneId> with fragment
    sed -i '' -e "s%<GlobalHostedZoneId>%$GLOBAL_HOSTEDZONE_FRAGMENT%" ./cloudformation/firerecord.template.yaml

    # AirCdnStack
    cp ./cloudformation/aircdn.yaml ./cloudformation/aircdn.template.yaml
    # - replace <GlobalTLSCertificateArn> with fragment
    sed -i '' -e "s%<GlobalTLSCertificateArn>%$GLOBAL_TLS_CERTIFICATE_ARN_FRAGMENT%" ./cloudformation/aircdn.template.yaml
    # - replace <Namespace> with fragment
    sed -i '' -e "s%<Namespace>%$NAMESPACE%" ./cloudformation/aircdn.template.yaml

    # EarthBucketStack
    cp ./cloudformation/earthbucket.yaml ./cloudformation/earthbucket.template.yaml
    # - replace <Namespace> with fragment
    sed -i '' -e "s%<Namespace>%$NAMESPACE%" ./cloudformation/earthbucket.template.yaml
    sed -i '' -e "s%<Namespace>%$NAMESPACE%" ./earthbucket-lambda-edge/index.js
    # - zip up EarthBucket Lambda@Edge code and upload
    zip -j ./build/lambda.zip ./earthbucket-lambda-edge/index.js
    aws s3 cp ./build/lambda.zip s3://$DEPLOYMENT_BUCKET/earthbucket-lambda-edge/ --profile $AWS_PROFILE

    # WaterApiStack
    cp ./cloudformation/waterapi.yaml ./cloudformation/waterapi.template.yaml
    # - replace <Namespace> with fragment
    sed -i '' -e "s%<Namespace>%$NAMESPACE%" ./cloudformation/waterapi.template.yaml
    # - replace <ParameterStoreNamespace> with fragment
    PARAMETERSTORE_NAMESPACE=$DOMAIN_NAME
    sed -i '' -e "s%<ParameterStoreNamespace>%$PARAMETERSTORE_NAMESPACE%" ./cloudformation/waterapi.template.yaml

    # WaterApiKeysStack
    cp ./cloudformation/waterapi-apikeys.yaml ./cloudformation/waterapi-apikeys.template.yaml
    # - replace <Namespace> with fragment
    sed -i '' -e "s%<Namespace>%$NAMESPACE%" ./cloudformation/waterapi-apikeys.template.yaml

    # sync cloudformation templates to s3
    aws s3 sync ./cloudformation s3://$DEPLOYMENT_BUCKET/cloudformation     \
      --delete                                                              \
      --exclude 'aircdn.yaml'                                               \
      --exclude 'earthbucket.yaml'                                          \
      --exclude 'environment.yaml'                                          \
      --exclude 'firerecord.yaml'                                           \
      --exclude 'global.yaml'                                               \
      --exclude 'waterapi.yaml'                                             \
      --exclude 'waterapi-apikeys.yaml'                                     \
      --profile $AWS_PROFILE

    # if bucket and/or lambda.zip file is not found
      # seed lambda with bucket and file
    WATERAPI_BUCKET="$NAMESPACE-$ENVIRONMENT"-waterapi-api
    aws s3api head-object --bucket $WATERAPI_BUCKET --key lambda.zip --profile $AWS_PROFILE || not_exist=true
    if [ $not_exist ]; then
      # make the thallium eli api bucket in case it doesn't exist
      aws s3 mb s3://$WATERAPI_BUCKET --profile $AWS_PROFILE
      # seed the bucket in case this file doesn't exist
      SEED_ZIPFILE=waterapi-lambda-seed.zip
      aws s3 cp scripts/$SEED_ZIPFILE s3://$WATERAPI_BUCKET --profile $AWS_PROFILE
      aws s3 mv s3://$WATERAPI_BUCKET/$SEED_ZIPFILE s3://$WATERAPI_BUCKET/lambda.zip --profile $AWS_PROFILE
    fi

    # generate next stage yaml file
    aws cloudformation package                                \
        --template-file $TEMPLATE                             \
        --output-template-file build/output.yaml              \
        --s3-bucket $DEPLOYMENT_BUCKET                        \
        --profile $AWS_PROFILE

    # the actual deployment step
    aws cloudformation deploy                                 \
        --template-file build/output.yaml                     \
        --stack-name $PROJECT                                 \
        --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND  \
        --profile $AWS_PROFILE                                \
        --parameter-overrides CacheHash=$CACHE_HASH DomainName=$FQDN DomainNameRedirect=$DOMAIN_NAME_REDIRECT Environment=$ENVIRONMENT TemplatesBucketName=$DEPLOYMENT_BUCKET

    # EarthBucketStack, WaterApiStack
    # - replace <AirCdnDistributionId> with fragment
    DISTRIBUTION_ID_FRAGMENT='AIRCDN_DISTRIBUTION_ID:\
            Fn::ImportValue:\
              !Sub "<Namespace>-${Environment}-AirCdnDistributionId"'
    sed -i '' -e "s%AIRCDN_DISTRIBUTION_ID: <AirCdnDistributionId>%$DISTRIBUTION_ID_FRAGMENT%" ./cloudformation/earthbucket.template.yaml
    sed -i '' -e "s%AIRCDN_DISTRIBUTION_ID: <AirCdnDistributionId>%$DISTRIBUTION_ID_FRAGMENT%" ./cloudformation/waterapi.template.yaml
    # - replace <Namespace> with fragment
    sed -i '' -e "s%<Namespace>%$NAMESPACE%" ./cloudformation/earthbucket.template.yaml
    sed -i '' -e "s%<Namespace>%$NAMESPACE%" ./cloudformation/waterapi.template.yaml

    aws s3 cp ./cloudformation/earthbucket.template.yaml s3://$DEPLOYMENT_BUCKET/cloudformation/earthbucket.template.yaml --profile $AWS_PROFILE
    aws s3 cp ./cloudformation/waterapi.template.yaml s3://$DEPLOYMENT_BUCKET/cloudformation/waterapi.template.yaml --profile $AWS_PROFILE

    # apply the above patch
    aws cloudformation deploy                                 \
        --template-file build/output.yaml                     \
        --stack-name $PROJECT                                 \
        --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND  \
        --profile $AWS_PROFILE                                \
        --parameter-overrides DomainName=$FQDN DomainNameRedirect=$DOMAIN_NAME_REDIRECT Environment=$ENVIRONMENT
  fi
fi