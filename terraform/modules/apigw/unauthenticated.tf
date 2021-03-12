data "template_file" "unauthenticated_api_swagger" {
  template = file("${path.module}/unauthenticated-api.yml")

  vars = {
    environment       = var.environment
    lambda_invoke_arn = var.waterapi_lambda_arn
    namespace         = var.namespace
  }
}
resource "aws_api_gateway_rest_api" "waterapi_unauthenticated_api" {
  name               = "${var.namespace}-${var.environment}-WaterApiUnauthenticatedApi"
  binary_media_types = ["*/*"]
  body               = data.template_file.unauthenticated_api_swagger.rendered
}

resource "aws_api_gateway_stage" "waterapi_unauthenticated_api_stage" {
  stage_name    = var.environment
  rest_api_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  deployment_id = aws_api_gateway_deployment.waterapi_unauthenticated_api_deployment.id
}

# resource "aws_api_gateway_domain_name" "waterapi_unauthenticated_api_domain" {
#   regional_certificate_arn = var.certificate_arn
#   domain_name              = var.domain_name

#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
# }

resource "aws_api_gateway_deployment" "waterapi_unauthenticated_api_deployment" {

  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id

  lifecycle {
    create_before_destroy = true
  }
}
