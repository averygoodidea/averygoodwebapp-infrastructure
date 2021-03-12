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
  # lambda_edge_function = module.lambda.basic_auth_lambda_function_arn
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

module "route53" {
  source = "./modules/route53"

  firerecord_zone       = var.firerecord_zone
  domain_name           = var.domain_name
  alias_distribution    = module.cloudfront.alias_distribution
  redirect_distribution = module.cloudfront.redirect_distribution
}

module "ses" {
  source = "./modules/ses"

  namespace   = var.namespace
  environment = var.environment
}
