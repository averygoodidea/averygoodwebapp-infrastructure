resource "aws_iam_role" "waterapi" {
  name = "${var.namespace}-${var.environment}-waterapi-lambda-role"

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

resource "aws_lambda_function" "waterapi" {
  s3_bucket     = "averygoodweb-app-${var.environment}-waterapi-api"
  s3_key        = "lambda.zip"
  function_name = "${var.namespace}-${var.environment}-waterapi"
  role          = aws_iam_role.waterapi.arn
  handler       = "index.handler"
  runtime = "nodejs12.x"

  environment {
    variables = {
      Namespace = var.namespace
    }
  }
}