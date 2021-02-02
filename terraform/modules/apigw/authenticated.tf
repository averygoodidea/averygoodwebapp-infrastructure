data "template_file" "swagger" {
  template = file("${path.module}/api.yml")

  vars = {
    environment = var.environment
  }
}
resource "aws_api_gateway_rest_api" "waterapi_authenticated_api" {
  name               = "${var.namespace}-${var.environment}-WaterApiAuthenticatedApi"
  binary_media_types = ["*/*"]
  body = data.template_file.swagger.rendered
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

# #############
# # Resources #
# #############

resource "aws_api_gateway_resource" "auth_api" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  parent_id   = aws_api_gateway_rest_api.waterapi_authenticated_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "auth_one" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  parent_id   = aws_api_gateway_resource.auth_api.id
  path_part   = "1"
}

resource "aws_api_gateway_resource" "auth_admin" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  parent_id   = aws_api_gateway_resource.auth_one.id
  path_part   = "admin"
}

resource "aws_api_gateway_resource" "auth_album" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  parent_id   = aws_api_gateway_resource.auth_admin.id
  path_part   = "album"
}

resource "aws_api_gateway_resource" "auth_post" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  parent_id   = aws_api_gateway_resource.auth_album.id
  path_part   = "post"
}

resource "aws_api_gateway_resource" "auth_posts" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  parent_id   = aws_api_gateway_resource.auth_album.id
  path_part   = "posts"
}

resource "aws_api_gateway_resource" "auth_id" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  parent_id   = aws_api_gateway_resource.auth_posts.id
  path_part   = "{id}"
}

resource "aws_api_gateway_resource" "auth_s3" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  parent_id   = aws_api_gateway_resource.auth_album.id
  path_part   = "s3"
}

resource "aws_api_gateway_resource" "auth_urls" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  parent_id   = aws_api_gateway_resource.auth_s3.id
  path_part   = "urls"
}

resource "aws_api_gateway_resource" "auth_images" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  parent_id   = aws_api_gateway_resource.auth_s3.id
  path_part   = "images"
}

resource "aws_api_gateway_resource" "auth_cache" {
  rest_api_id = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  parent_id   = aws_api_gateway_resource.auth_admin.id
  path_part   = "cloudfront-cache"
}

# #############
# # Methods #
# #############

resource "aws_api_gateway_method" "auth_post_post_method" {
  rest_api_id      = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id      = aws_api_gateway_resource.auth_post.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "auth_post_options_method" {
  rest_api_id      = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id      = aws_api_gateway_resource.auth_post.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "auth_id_put_method" {
  rest_api_id      = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id      = aws_api_gateway_resource.auth_id.id
  http_method      = "PUT"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "auth_id_delete_method" {
  rest_api_id      = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id      = aws_api_gateway_resource.auth_id.id
  http_method      = "DELETE"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "auth_id_options_method" {
  rest_api_id      = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id      = aws_api_gateway_resource.auth_id.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "auth_urls_get_method" {
  rest_api_id      = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id      = aws_api_gateway_resource.auth_urls.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "auth_urls_options_method" {
  rest_api_id      = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id      = aws_api_gateway_resource.auth_urls.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "auth_images_delete_method" {
  rest_api_id      = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id      = aws_api_gateway_resource.auth_images.id
  http_method      = "DELETE"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "auth_images_options_method" {
  rest_api_id      = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id      = aws_api_gateway_resource.auth_images.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "auth_cache_delete_method" {
  rest_api_id      = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id      = aws_api_gateway_resource.auth_cache.id
  http_method      = "DELETE"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "auth_cache_options_method" {
  rest_api_id      = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id      = aws_api_gateway_resource.auth_cache.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = true
}

# ################
# # Integrations #
# ################

resource "aws_api_gateway_integration" "auth_post_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id             = aws_api_gateway_resource.auth_post.id
  http_method             = aws_api_gateway_method.auth_post_post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "auth_post_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id             = aws_api_gateway_resource.auth_post.id
  http_method             = aws_api_gateway_method.auth_post_options_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "auth_id_put_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id             = aws_api_gateway_resource.auth_id.id
  http_method             = aws_api_gateway_method.auth_id_put_method.http_method
  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "auth_id_delete_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id             = aws_api_gateway_resource.auth_id.id
  http_method             = aws_api_gateway_method.auth_id_delete_method.http_method
  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "auth_id_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id             = aws_api_gateway_resource.auth_id.id
  http_method             = aws_api_gateway_method.auth_id_options_method.http_method
  integration_http_method = "OPTIONS"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "auth_urls_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id             = aws_api_gateway_resource.auth_urls.id
  http_method             = aws_api_gateway_method.auth_urls_get_method.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "auth_urls_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id             = aws_api_gateway_resource.auth_urls.id
  http_method             = aws_api_gateway_method.auth_urls_options_method.http_method
  integration_http_method = "OPTIONS"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "auth_images_delete_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id             = aws_api_gateway_resource.auth_images.id
  http_method             = aws_api_gateway_method.auth_images_delete_method.http_method
  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "auth_images_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id             = aws_api_gateway_resource.auth_images.id
  http_method             = aws_api_gateway_method.auth_images_options_method.http_method
  integration_http_method = "OPTIONS"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "auth_cache_delete_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id             = aws_api_gateway_resource.auth_cache.id
  http_method             = aws_api_gateway_method.auth_cache_delete_method.http_method
  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration" "auth_cache_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  resource_id             = aws_api_gateway_resource.auth_cache.id
  http_method             = aws_api_gateway_method.auth_cache_options_method.http_method
  integration_http_method = "OPTIONS"
  type                    = "AWS_PROXY"
  uri                     = var.waterapi_lambda_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

# ##############
# # Deployment #
# ##############

resource "aws_api_gateway_deployment" "waterapi_authenticated_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.auth_post_post_integration,
    aws_api_gateway_integration.auth_post_options_integration,
    aws_api_gateway_integration.auth_id_put_integration,
    aws_api_gateway_integration.auth_id_delete_integration,
    aws_api_gateway_integration.auth_id_options_integration,
    aws_api_gateway_integration.auth_images_delete_integration,
    aws_api_gateway_integration.auth_images_options_integration,
    aws_api_gateway_integration.auth_cache_delete_integration,
    aws_api_gateway_integration.auth_cache_options_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.waterapi_authenticated_api.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "waterapi_authenticated_api_stage" {
  stage_name    = var.environment
  rest_api_id   = aws_api_gateway_rest_api.waterapi_authenticated_api.id
  deployment_id = aws_api_gateway_deployment.waterapi_authenticated_api_deployment.id
}

# resource "aws_api_gateway_base_path_mapping" "waterapi_authenticated_api_mapping" {
#   api_id      = aws_api_gateway_rest_api.waterapi_authenticated_api.id
#   stage_name  = aws_api_gateway_deployment.waterapi_authenticated_api_deployment.stage_name
#   domain_name = var.domain_name
#   base_path   = var.environment
# }