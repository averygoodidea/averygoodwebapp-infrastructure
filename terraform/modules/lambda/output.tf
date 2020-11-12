output "waterapi_lambda_function_arn" {
    value = aws_lambda_function.waterapi_lambda_function.arn
}

output "waterapi_lambda_function_invoke_arn" {
    value = aws_lambda_function.waterapi_lambda_function.invoke_arn
}