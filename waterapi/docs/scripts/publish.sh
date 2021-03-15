ENVIRONMENT=${1:-dev}
AWS_PROFILE=$2
[[ $ENVIRONMENT = 'prod' ]] && ENV_FILE=.env.production || ENV_FILE=.env.development
export $(grep -v '^#' "../$ENV_FILE" | xargs)
NAMESPACE=$(sed -e "s,\.,-," <<< $DOMAIN_NAME)
sh ./scripts/render.sh $ENVIRONMENT --profile $AWS_PROFILE
aws s3 sync ./build s3://$AWS_WATERAPI_DOCS_BUCKET --delete --exclude '*.DS_Store' --profile $AWS_PROFILE
CLOUDFRONT_DISTRIBUTION_ID=$(aws cloudformation list-exports --query "Exports[?Name=='${NAMESPACE}-${ENVIRONMENT}-AirCdnDistributionId'].Value" --output text --profile $AWS_PROFILE)
aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths '/*' --profile $AWS_PROFILE
[[ $ENVIRONMENT != prod ]] && SUBDOMAIN="$ENVIRONMENT". || SUBDOMAIN=""
echo "------------------"
echo "${DOMAIN_NAME} api docs published! You can view them here:"
echo "https://${DOMAIN_NAME}/api/1/docs/"
echo "------------------"