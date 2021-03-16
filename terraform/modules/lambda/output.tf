output "waterapi_lambda_function_arn" {
  value = aws_lambda_function.api.arn
}

output "waterapi_lambda_function_invoke_arn" {
  value = aws_lambda_function.api.invoke_arn
}

output "waterapi_lambda_function_name" {
  value = aws_lambda_function.api.function_name
}

# output "cache_invalidation_lambda_function_arn" {
#   value = aws_lambda_function.cache_invalidation.arn
# }

# output "cache_invalidation_lambda_function_invoke_arn" {
#   value = aws_lambda_function.cache_invalidation.invoke_arn
# }

output "basic_auth_lambda_function_arn" {
  value = aws_lambda_function.basic_auth.qualified_arn
}