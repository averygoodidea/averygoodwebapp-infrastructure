output "api_key_id" {
  value = aws_api_gateway_api_key.waterapi_authenticated_api.id
}

output "api_key_arn" {
  value = aws_api_gateway_api_key.waterapi_authenticated_api.arn
}

output "api_key" {
  value = aws_api_gateway_api_key.waterapi_authenticated_api.value
}