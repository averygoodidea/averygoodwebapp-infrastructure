while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

  shift
done

if [ -z $profile ]; then
    echo "\nYou didn't provide a '--profile <awsProfile>' value. Exiting.\n"
    exit 1
elif [ -z $environment ]; then
    echo "\nYou didn't provide an '--environment <environment>' value. Exiting.\n"
    exit 1
fi

# $1 ENVIRONMENT
# $2 PROFILE
ENVIRONMENT=$environment
AWS_PROFILE=$profile

ENV_FILE=./env/.env.$environment
export $(grep -v '^#' $ENV_FILE | xargs)
NAMESPACE=${DOMAIN_NAME//./-}
DEPLOYMENT_BUCKET=$AWS_WATERAPI_DEPLOYMENT_BUCKET
DISTRIBUTION_ID=$AWS_AIRCDN_DISTRIBUTION_ID

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
LAMBDA=$AWS_WATERAPI_FUNCTION_NAME
aws lambda update-function-code					\
	--function-name $LAMBDA						\
	--s3-bucket $DEPLOYMENT_BUCKET				\
	--s3-key lambda.zip							\
	--profile $AWS_PROFILE

# clear any cache at the BronzeEden level
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths '/api/*' --profile $AWS_PROFILE