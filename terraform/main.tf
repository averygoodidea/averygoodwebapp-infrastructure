module "firerecord" {
    source = "./modules/firerecord"

    # aircdn_hosted_zone = "blah"
    # aircdn_redirect_domain_name = module.aircdnstack.aircdnredirect
    # aircdn_domain_name  = var.aircdn_domain_name
    firerecord_zone = var.firerecord_zone
    domain_name = var.domain_name
    # domain_name_redirect = var.domain_name_redirect
}

module "waterapi_apigw" {
    source = "./modules/apigw"
    waterapi_lambda_arn = module.waterapi_lambda.waterapi_lambda_function_invoke_arn
    certificate_arn = module.firerecord.waterapi_certificate_arn
    domain_name = var.domain_name
}

module "waterapi_lambda" {
    source = "./modules/lambda"
}
