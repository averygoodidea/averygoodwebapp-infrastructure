output "api_key_id" {
  value = aws_api_gateway_api_key.waterapi_authenticated_api.id
}

output "api_key_arn" {
  value = aws_api_gateway_api_key.waterapi_authenticated_api.arn
}

output "api_key" {
  value = aws_api_gateway_api_key.waterapi_authenticated_api.value
}

output "authenticated_api_url" {
  value = aws_api_gateway_deployment.waterapi_authenticated_api_deployment.invoke_url
}

output "unauthenticated_api_url" {
  value = aws_api_gateway_deployment.waterapi_unauthenticated_api_deployment.invoke_url
}