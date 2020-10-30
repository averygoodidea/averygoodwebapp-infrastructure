resource "aws_api_gateway_rest_api" "waterapi_unauthenticated_api" {
  name        = "${var.namespace}-${var.environment}-WaterApiUnauthenticatedApi"
  binary_media_types = "*/*"
}

resource "aws_api_gateway_stage" "waterapi_unauthenticated_api_stage" {
  stage_name    = var.environment
  rest_api_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  deployment_id = aws_api_gateway_deployment.waterapi_unauthenticated_api.id
}

resource "aws_api_gateway_base_path_mapping" "waterapi_unauthenticated_api_mapping" {
  api_id      = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  stage_name  = aws_api_gateway_deployment.waterapi_unauthenticated_api.stage_name
  domain_name = aws_api_gateway_domain_name.waterapi_unauthenticated_api.domain_name
}

resource "aws_api_gateway_resource" "waterapi_unauthenticated_api_resource_a" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  parent_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.root_resource_id
  path_part   = "/api/1/album/posts"
}

resource "aws_api_gateway_method" "waterapi_unauthenticated_api_resource_get_method_a" {
  rest_api_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id   = aws_api_gateway_resource.waterapi_unauthenticated_api_resource_a.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "waterapi_unauthenticated_api_resource_get_integration_a" {
  rest_api_id          = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id          = aws_api_gateway_resource.waterapi_unauthenticated_api_resource_a.id
  http_method          = aws_api_gateway_method.waterapi_unauthenticated_api_resource_get_method.http_method
  type                 = "AWS_PROXY"
  uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.waterapi_lambda_arn}/invocations"
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_method" "waterapi_unauthenticated_api_resource_options_method_a" {
  rest_api_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id   = aws_api_gateway_resource.waterapi_unauthenticated_api_resource_a.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "waterapi_unauthenticated_api_resource_options_integration_a" {
  rest_api_id          = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id          = aws_api_gateway_resource.waterapi_unauthenticated_api_resource_a.id
  http_method          = aws_api_gateway_method.waterapi_unauthenticated_api_resource_options_method.http_method
  type                 = "AWS_PROXY"
  uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.waterapi_lambda_arn}/invocations"
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_resource" "waterapi_unauthenticated_api_resource_b" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  parent_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "waterapi_unauthenticated_api_resource_any_method_b" {
  rest_api_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id   = aws_api_gateway_resource.waterapi_unauthenticated_api_resource_b.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "waterapi_unauthenticated_api_resource_post_integration_b" {
  rest_api_id          = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id          = aws_api_gateway_resource.waterapi_unauthenticated_api_resource_b.id
  http_method          = aws_api_gateway_method.waterapi_unauthenticated_api_resource_post_method_b.http_method
  type                 = "AWS_PROXY"
  uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.waterapi_lambda_arn}/invocations"
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_resource" "waterapi_unauthenticated_api_resource_c" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  parent_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.root_resource_id
  path_part   = "/api/1/admin/magic-link"
}

resource "aws_api_gateway_method" "waterapi_unauthenticated_api_resource_post_method_c" {
  rest_api_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id   = aws_api_gateway_resource.waterapi_unauthenticated_api_resource_b.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "waterapi_unauthenticated_api_resource_post_integration_c" {
  rest_api_id          = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id          = aws_api_gateway_resource.waterapi_unauthenticated_api_resource_b.id
  http_method          = aws_api_gateway_method.waterapi_unauthenticated_api_resource_post_method_b.http_method
  type                 = "AWS_PROXY"
  uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.waterapi_lambda_arn}/invocations"
  passthrough_behavior = "WHEN_NO_MATCH"
}