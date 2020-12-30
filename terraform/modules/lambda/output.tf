output "waterapi_lambda_function_arn" {
  value = aws_lambda_function.waterapi.arn
}

output "waterapi_lambda_function_invoke_arn" {
  value = aws_lambda_function.waterapi.invoke_arn
}

output "cache_invalidation_lambda_function_arn" {
  value = aws_lambda_function.cache_invalidation.arn
}

output "cache_invalidation_lambda_function_invoke_arn" {
  value = aws_lambda_function.cache_invalidation.invoke_arn
}