resource "random_string" "basic_auth" {
  length  = 4
  special = false
}

data "archive_file" "basic_auth" {
  type        = "zip"
  output_path = "tmp/basic_auth.zip"

  source_file = "${path.module}/lambda_handlers/basic_auth.js"
}

resource "aws_lambda_function" "basic_auth" {
  filename         = data.archive_file.basic_auth.output_path
  source_code_hash = filebase64sha256(data.archive_file.basic_auth.output_path)
  function_name    = "${var.namespace}-${var.environment}-LambdaEdge-${random_string.basic_auth.result}"
  role             = aws_iam_role.basic_auth.arn
  handler          = "index.handler"
  memory_size      = 128
  timeout          = 5
  runtime          = "nodejs10.x"
}

resource "random_id" "basic_auth" {
  byte_length = 4
}

resource "aws_lambda_alias" "basic_auth" {
  name             = "${var.namespace}-${var.environment}-${random_id.basic_auth.id}-EarthBucketBasicAuthLambdaEdge-alias"
  function_name    = aws_lambda_function.basic_auth.function_name
  function_version = "$LATEST"
}

resource "aws_iam_role" "basic_auth" {
  name = "${var.namespace}-${var.environment}-${random_id.basic_auth.id}-EarthBucketBasicAuthLambdaEdge-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "basic_auth" {
  name        = "${var.namespace}-${var.environment}-${random_id.basic_auth.id}-EarthBucketBasicAuthLambdaEdge-policy"
  path        = "/"
  description = "IAM policy for Lambda access to DynamoDB"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "dynamodb:*",
      "Resource": "arn:aws:dynamodb:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "basic_auth" {
  role       = aws_iam_role.basic_auth.name
  policy_arn = aws_iam_policy.basic_auth.arn
}