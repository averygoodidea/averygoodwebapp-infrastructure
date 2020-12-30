module "cloudfront" {
  source = "./modules/cloudfront"

  domain_name = var.domain_name
  redirect_domain_name = var.redirect_domain_name
  namespace   = var.namespace
  environment = var.environment
  region      = var.region
  lambda_edge_function = module.lambda.cache_invalidation_lambda_function_arn
  certificate_arn     = module.dns.ssl_certificate_arn
}

module "sqs" {
  source = "./modules/sqs"

  namespace   = var.namespace
  environment = var.environment
}
module "s3" {
  source = "./modules/s3"

  domain_name = var.domain_name
  namespace   = var.namespace
  environment = var.environment
  queue_arn = module.sqs.sqs_queue_arn
}
module "dns" {
  source = "./modules/dns"

  firerecord_zone = var.firerecord_zone
  domain_name     = var.domain_name
}

module "apigw" {
  source = "./modules/apigw"

  waterapi_lambda_arn = module.lambda.waterapi_lambda_function_invoke_arn
  certificate_arn     = module.dns.ssl_certificate_arn
  namespace           = var.namespace
  environment         = var.environment
  domain_name         = var.domain_name
  region              = var.region
}

module "lambda" {
  source = "./modules/lambda"

  namespace   = var.namespace
  environment = var.environment
  domain_name = var.domain_name
  region      = var.region
  queue_arn = module.sqs.sqs_queue_arn
  queue_url = module.sqs.sqs_queue_url
  aircdn_distribution_id = module.cloudfront.aircdn_distribution_id
}