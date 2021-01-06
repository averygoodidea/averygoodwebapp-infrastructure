resource "aws_api_gateway_rest_api" "waterapi_unauthenticated_api" {
  name               = "${var.namespace}-${var.environment}-WaterApiUnauthenticatedApi"
  binary_media_types = ["*/*"]
}

resource "aws_api_gateway_stage" "waterapi_unauthenticated_api_stage" {
  stage_name    = var.environment
  rest_api_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  deployment_id = aws_api_gateway_deployment.waterapi_unauthenticated_api_deployment.id
}

resource "aws_api_gateway_domain_name" "waterapi_unauthenticated_api_domain" {
  regional_certificate_arn = var.certificate_arn
  domain_name              = var.domain_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "waterapi_unauthenticated_api_mapping" {
  api_id      = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  stage_name  = aws_api_gateway_deployment.waterapi_unauthenticated_api_deployment.stage_name
  domain_name = aws_api_gateway_domain_name.waterapi_unauthenticated_api_domain.domain_name
  base_path   = ""
}

#############
# Resources #
#############

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  parent_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "one" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "1"
}

resource "aws_api_gateway_resource" "admin" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  parent_id   = aws_api_gateway_resource.one.id
  path_part   = "admin"
}

resource "aws_api_gateway_resource" "album" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  parent_id   = aws_api_gateway_resource.one.id
  path_part   = "album"
}

resource "aws_api_gateway_resource" "posts" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  parent_id   = aws_api_gateway_resource.album.id
  path_part   = "posts"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  parent_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_resource" "magic_link" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  parent_id   = aws_api_gateway_resource.admin.id
  path_part   = "magic-link"
}

resource "aws_api_gateway_resource" "hash" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  parent_id   = aws_api_gateway_resource.admin.id
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

resource "aws_api_gateway_method" "magic_link_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id   = aws_api_gateway_resource.magic_link.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "magic_link_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id   = aws_api_gateway_resource.magic_link.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "hash_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id   = aws_api_gateway_resource.hash.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "hash_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id   = aws_api_gateway_resource.hash.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "proxy_any_method" {
  rest_api_id   = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}


################
# Integrations #
################

resource "aws_api_gateway_integration" "posts_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id             = aws_api_gateway_resource.posts.id
  http_method             = aws_api_gateway_method.posts_get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "posts_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id             = aws_api_gateway_resource.posts.id
  http_method             = aws_api_gateway_method.posts_options_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "magic_link_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id             = aws_api_gateway_resource.magic_link.id
  http_method             = aws_api_gateway_method.magic_link_post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "magic_link_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id             = aws_api_gateway_resource.magic_link.id
  http_method             = aws_api_gateway_method.magic_link_options_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "hash_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id             = aws_api_gateway_resource.hash.id
  http_method             = aws_api_gateway_method.hash_get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "hash_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id             = aws_api_gateway_resource.hash.id
  http_method             = aws_api_gateway_method.hash_options_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "proxy_any_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_any_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

##############
# Deployment #
##############

resource "aws_api_gateway_deployment" "waterapi_unauthenticated_api_deployment" {
  depends_on = [aws_api_gateway_integration.posts_get_integration]

  rest_api_id = aws_api_gateway_rest_api.waterapi_unauthenticated_api.id

  lifecycle {
    create_before_destroy = true
  }
}
