module "route53" {
  source = "./modules/route53"

  firerecord_zone       = var.firerecord_zone
  domain_name           = var.domain_name
  alias_distribution    = module.cloudfront.alias_distribution
  redirect_distribution = module.cloudfront.redirect_distribution
}

module "acm" {
  source = "./modules/acm"

  firerecord_zone = var.firerecord_zone
  domain_name     = var.domain_name
}
module "apigw" {
  source = "./modules/apigw"

  waterapi_lambda_arn = module.lambda.waterapi_lambda_function_invoke_arn
  certificate_arn     = module.acm.ssl_certificate_arn
  namespace           = var.namespace
  environment         = var.environment
  domain_name         = var.domain_name
  region              = var.region
}
module "cloudfront" {
  source = "./modules/cloudfront"

  domain_name = var.domain_name
  namespace   = var.namespace
  environment = var.environment
  region      = var.region
  basic_auth_lambda_edge_function_arn = module.lambda.basic_auth_lambda_function_arn
  unauthenticated_api_url = module.apigw.unauthenticated_api_url
  authenticated_api_url   = module.apigw.authenticated_api_url
  certificate_arn         = module.acm.ssl_certificate_arn
}

module "dynamodb" {
  source = "./modules/dynamodb"

  namespace   = var.namespace
  environment = var.environment
  region      = var.region
}
module "lambda" {
  source = "./modules/lambda"

  namespace   = var.namespace
  environment = var.environment
  domain_name = var.domain_name
  region      = var.region
  # queue_arn              = module.sqs.sqs_queue_arn
  # queue_url              = module.sqs.sqs_queue_url
  # aircdn_distribution_id = module.cloudfront.aircdn_distribution_id
  album_posts_table    = module.dynamodb.album_posts_table
  admin_table          = module.dynamodb.admin_table
  basic_auth_table     = module.dynamodb.basic_auth_table
  gatsby_webhook_id    = var.gatsby_webhook_id
  sender_email_address = var.sender_email_address
}
# module "sqs" {
#   source = "./modules/sqs"

#   namespace   = var.namespace
#   environment = var.environment
# }
module "s3" {
  source = "./modules/s3"

  domain_name = var.domain_name
  namespace   = var.namespace
  environment = var.environment
  # queue_arn   = module.sqs.sqs_queue_arn
}

module "ses" {
  source = "./modules/ses"

  namespace   = var.namespace
  environment = var.environment
}

resource "local_file" "waterapi_env_vars" {
    content  = <<EOF
AWS_AIRCDN_DISTRIBUTION_ID=${module.cloudfront.aircdn_distribution_id}
AWS_WATERAPI_DOCS_BUCKET=${var.namespace}-${var.environment}-waterapi-docs
AWS_WATERAPI_DEPLOYMENT_BUCKET=${var.namespace}-${var.environment}-waterapi-api
AWS_WATERAPI_EMAIL=${var.sender_email_address}
AWS_WATERAPI_KEY=${module.apigw.api_key}
AWS_WATERAPI_FUNCTION_NAME=${module.lambda.waterapi_lambda_function_name}
DOMAIN_NAME=${var.domain_name}
EOF
    filename = "${path.module}/../waterapi/env/.env.${var.environment}"
}

resource "local_file" "earthbucket_env_vars" {
    content  = <<EOF
AWS_ACCESS_KEY_ID=${var.aws_access_key_id}
AWS_EARTHBUCKET_APP_BUCKET=${var.namespace}-${var.environment}-earthbucket-app
AWS_EARTHBUCKET_DOCS_BUCKET=${var.namespace}-${var.environment}-earthbucket-docs
AWS_EARTHBUCKET_MEDIA_BUCKET=${var.namespace}-${var.environment}-earthbucket-media
AWS_REGION=${var.region}
AWS_SECRET_ACCESS_KEY=${var.aws_secret_access_key}
GATSBY_EARTHBUCKET_HOSTNAME=${var.domain_name}
GATSBY_TINYLETTER_USERNAME=${var.tinyletter_username}
GATSBY_WATERAPI_KEY=${module.apigw.api_key}
VALINE_LEANCLOUD_APP_ID=${var.valine_leancloud_app_id}
VALINE_LEANCLOUD_APP_KEY=${var.valine_leancloud_app_key}  
EOF
    filename = "${path.module}/../earthbucket/.env.${var.environment}"
}