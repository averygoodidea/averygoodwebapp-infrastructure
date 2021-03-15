# $1 ENVIRONMENT
# $2 PROFILE
ENVIRONMENT=${1:-dev}
AWS_PROFILE=$2
[[ $ENVIRONMENT = 'prod' ]] && ENV_FILE=.env.production || ENV_FILE=.env.development
export $(grep -v '^#' $ENV_FILE | xargs)
NAMESPACE=$(sed -e "s,\.,-," <<< $DOMAIN_NAME)
PROJECT="$NAMESPACE-$ENVIRONMENT"-waterapi-api
DEPLOYMENT_BUCKET=$PROJECT

#npm run test:units

# make a build directory to store lambda artifacts
rm -rf build
mkdir build

# - convert this src code into a "Lambda structured" zip file
zip build/lambda.zip * -r -x 					\
	.git/\* 									\
	README.md\*									\
	package\*									\
	node_modules/aws-sdk/\* 					\
	test/\*										\
	\*.sh 										\
	\*.test.js									\
	build/\* 									\
	\*.zip										\
	api/\*										\
	scripts/\*									\

# - upload the zip file to an [Environment]-waterapi s3 bucket
# - - make the deployment bucket in case it doesn't exist
aws s3 mb s3://$DEPLOYMENT_BUCKET --profile $AWS_PROFILE
aws s3 cp build/lambda.zip s3://$DEPLOYMENT_BUCKET --profile $AWS_PROFILE

# - update the aws cloudformation lambda to pull in the newly uploaded file from that s3 bucket.
LAMBDA="$NAMESPACE"-"$ENVIRONMENT"-WaterApiLambda
aws lambda update-function-code					\
	--function-name $LAMBDA						\
	--s3-bucket $DEPLOYMENT_BUCKET				\
	--s3-key lambda.zip							\
	--profile $AWS_PROFILE

# clear any cache at the BronzeEden level
DISTRIBUTION_ID=$(aws cloudformation list-exports --query "Exports[?Name=='${NAMESPACE}-${ENVIRONMENT}-AirCdnDistributionId'].Value" --output text --profile $AWS_PROFILE)
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths '/api/*' --profile $AWS_PROFILE