data "aws_cloudfront_distribution" "cache_invalidation" {
  id = var.aircdn_distribution_id
}
resource "random_uuid" "cache_invalidation" {}

data "archive_file" "cache_invalidation" {
  type        = "zip"
  output_path = "tmp/cache_invalidation.zip"

  source_file = "${path.module}/lambda_handlers/cache_invalidation.js"
}

resource "aws_lambda_function" "cache_invalidation" {
  filename = data.archive_file.cache_invalidation.output_path
  source_code_hash = filebase64sha256(data.archive_file.cache_invalidation.output_path)
  function_name = "${var.namespace}-${var.environment}-EarthBucketCacheInvalidator"
  role          = aws_iam_role.cache_invalidation.arn
  handler       = "index.handler"
  memory_size = 120
  timeout      = 20
  runtime = "nodejs12.x"
  environment {
    variables = {
      "AIRCDN_DISTRIBUTION_ID" = data.aws_cloudfront_distribution.cache_invalidation.id
      "QUEUE_URL" = var.queue_url,
      "REGION" = var.region
    }

  }
}

resource "aws_lambda_event_source_mapping" "cache_invalidation" {
  event_source_arn = var.queue_arn
  batch_size = 10
  function_name    = aws_lambda_function.cache_invalidation.arn
}


resource "aws_iam_role" "cache_invalidation" {
  name = "${var.namespace}-${var.environment}-EarthBucketCacheInvalidator-role"

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

resource "aws_iam_policy" "cache_invalidation" {
  name        = "${var.namespace}-${var.environment}-EarthBucketCacheInvalidator-policy"
  path        = "/"
  description = "IAM policy for Lambda access to DynamoDB"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ChangeMessageVisibility"
      ],
      "Resource": "${var.queue_arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cache_invalidation" {
  role       = aws_iam_role.cache_invalidation.name
  policy_arn = aws_iam_policy.cache_invalidation.arn
}