resource "aws_api_gateway_rest_api" "waterapi_unauthenticated_api" {
  name        = "${var.namespace}-${var.environment}-WaterApiUnauthenticatedApi"
  binary_media_types = ["*/*"]
}

resource "aws_api_gateway_stage" "waterapi_unauthenticated_api_stage" {
  stage_name    = var.environment
  rest_api_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  deployment_id = aws_api_gateway_deployment.waterapi_unauthenticated_api_deployment.id
}

# data "aws_acm_certificate" "waterapi_acm_certificate" {
#   domain   = var.domain_name
#   statuses = ["ISSUED"]
# }

resource "aws_api_gateway_domain_name" "waterapi_unauthenticated_api_domain" {
  certificate_arn = var.certificate_arn
  domain_name     = var.domain_name
}

resource "aws_api_gateway_base_path_mapping" "waterapi_unauthenticated_api_mapping" {
  api_id      = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  stage_name  = aws_api_gateway_deployment.waterapi_unauthenticated_api_deployment.stage_name
  domain_name = aws_api_gateway_domain_name.waterapi_unauthenticated_api_domain.domain_name
}

#############
# Resources #
#############

resource "aws_api_gateway_resource" "posts" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  parent_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.root_resource_id
  path_part   = "posts"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  parent_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_resource" "magic_link" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  parent_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.root_resource_id
  path_part   = "magic-link"
}

resource "aws_api_gateway_resource" "hash" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  parent_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.root_resource_id
  path_part   = "hash"
}

#############
# Methods #
#############

resource "aws_api_gateway_method" "posts_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id   = aws_api_gateway_resource.posts.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "posts_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id   = aws_api_gateway_resource.posts.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

################
# Integrations #
################

resource "aws_api_gateway_integration" "posts_get_integration" {
  rest_api_id          = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id          = aws_api_gateway_resource.posts.id
  http_method          = aws_api_gateway_method.posts_get_method.http_method
  integration_http_method = "POST"
  type                 = "AWS_PROXY"
  uri                  = var.waterapi_lambda_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "posts_options_integration" {
  rest_api_id          = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id          = aws_api_gateway_resource.posts.id
  http_method          = aws_api_gateway_method.posts_options_method.http_method
  integration_http_method = "POST"
  type                 = "AWS_PROXY"
  uri                  = var.waterapi_lambda_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

#############
# Others... #
#############

resource "aws_api_gateway_deployment" "waterapi_unauthenticated_api_deployment" {
  depends_on = [aws_api_gateway_integration.posts_get_integration]

  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id

  lifecycle {
    create_before_destroy = true
  }
}
