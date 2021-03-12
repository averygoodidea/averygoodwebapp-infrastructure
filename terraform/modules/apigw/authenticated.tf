data "template_file" "authenticated_api_swagger" {
  template = file("${path.module}/authenticated-api.yml")

  vars = {
    environment       = var.environment
    lambda_invoke_arn = var.waterapi_lambda_arn
    namespace         = var.namespace
  }
}
resource "aws_api_gateway_rest_api" "waterapi_authenticated_api" {
  name               = "${var.namespace}-${var.environment}-WaterApiAuthenticatedApi"
  binary_media_types = ["*/*"]
  body               = data.template_file.authenticated_api_swagger.rendered
}
resource "aws_api_gateway_api_key" "waterapi_authenticated_api" {
  name    = aws_api_gateway_rest_api.waterapi_authenticated_api.name
  enabled = true
}

# resource "aws_api_gateway_domain_name" "waterapi_authenticated_api_domain" {
#   regional_certificate_arn = var.certificate_arn
#   domain_name              = var.domain_name

#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
# }

resource "aws_api_gateway_deployment" "waterapi_authenticated_api_deployment" {
  rest_api_id       = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  stage_description = file("${path.module}/api.yml")

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_api_gateway_stage" "waterapi_authenticated_api_stage" {
  stage_name    = var.environment
  rest_api_id   = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  deployment_id = aws_api_gateway_deployment.waterapi_authenticated_api_deployment.id
}