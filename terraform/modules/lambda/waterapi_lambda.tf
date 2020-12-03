resource "aws_iam_role" "waterapi_lambda_role" {
  name = "${var.namespace}-${var.environment}-waterapi_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "waterapi_lambda_file" {
  type        = "zip"
  output_path = "tmp/waterapi_lambda.zip"

  source_dir = "${path.module}/lambda_handlers/earthbucket"
}


resource "aws_lambda_function" "waterapi_lambda_function" {
  s3_bucket     = "averygoodweb-app-dev-waterapi-api"
  s3_key        = "lambda.zip"
  function_name = "${var.namespace}-${var.environment}-waterapi_lambda_role"
  role          = aws_iam_role.waterapi_lambda_role.arn
  handler       = "index.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  # source_code_hash = data.archive_file.waterapi_lambda_file.output_base64sha256

  runtime = "nodejs12.x"

}