#!/bin/bash
AWS_PROFILE=$1
export $(grep -v '^#' .env | xargs)
echo "upload parameters into AWS parameter store..."
# global parameters
aws ssm delete-parameter	--name 		"/${DOMAIN_NAME}/global/waterapi/gatsbyjs.com/WEBHOOK_ID" --profile $AWS_PROFILE
aws ssm put-parameter 		--name 		"/${DOMAIN_NAME}/global/waterapi/gatsbyjs.com/WEBHOOK_ID"			\
							--type 		"String"															\
							--value		"$GATSBY_WEBHOOK_ID"														\
							--overwrite 																	\
							--profile $AWS_PROFILE															\
							--description "The id used to invoke the Gatsby Cloud webhook."
# prod parameters
aws ssm delete-parameter	--name 		"/${DOMAIN_NAME}/prod/waterapi/SES_SENDER_EMAIL_ADDRESS" --profile $AWS_PROFILE
aws ssm put-parameter 		--name 		"/${DOMAIN_NAME}/prod/waterapi/SES_SENDER_EMAIL_ADDRESS"			\
							--type 		"String"															\
							--value		"$AWS_WATERAPI_EMAIL"													\
							--overwrite 																	\
							--profile $AWS_PROFILE															\
							--description "An environment credential needed for WaterApiSES to send magic link emails."
# dev parameters
aws ssm delete-parameter	--name 		"/${DOMAIN_NAME}/dev/waterapi/SES_SENDER_EMAIL_ADDRESS" --profile $AWS_PROFILE
aws ssm put-parameter 		--name 		"/${DOMAIN_NAME}/dev/waterapi/SES_SENDER_EMAIL_ADDRESS"				\
							--type 		"String"															\
							--value		"$AWS_WATERAPI_EMAIL"													\
							--overwrite 																	\
							--profile $AWS_PROFILE															\
							--description "An environment credential needed for WaterApiSES to send magic link emails."
echo "parameters uploaded!"
# deploy global stack
sh ./scripts/deploy.sh global $AWS_PROFILE
echo "\nglobal stack initialized!"