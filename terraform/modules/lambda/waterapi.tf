resource "random_id" "api" {
  byte_length = 4
}
locals {
  package_url = "https://raw.githubusercontent.com/averygoodidea/averygoodwebapp-waterapi/master/index.js"
  downloaded  = "downloaded_package_${md5(local.package_url)}.js"
  zipped      = "downloaded_package_${md5(local.package_url)}.zip"
}

resource "null_resource" "download_package" {
  triggers = {
    downloaded = local.downloaded
  }

  provisioner "local-exec" {
    command = "curl -L -o ${local.downloaded} ${local.package_url}  && zip -r ${local.zipped} ${local.downloaded}"
  }
}

data "null_data_source" "downloaded_package" {
  inputs = {
    id       = null_resource.download_package.id
    filename = local.zipped
  }
}

resource "aws_lambda_function" "api" {
  filename      = data.null_data_source.downloaded_package.outputs["filename"]
  function_name = "${var.namespace}-${var.environment}-${random_id.api.id}-waterapi"
  role          = aws_iam_role.api.arn
  handler       = "index.handler"
  runtime       = "nodejs12.x"

  environment {
    variables = {
      ALLOWED_MAGICLINK_URL         = var.domain_name
      ENVIRONMENT                   = var.environment
      GATSBY_WEBHOOK_ID             = var.gatsby_webhook_id
      ALBUM_POSTS_TABLE             = var.album_posts_table
      ADMINS_TABLE                  = var.admin_table
      EARTHBUCKET_MEDIA_BUCKET_NAME = "${var.namespace}-${var.environment}-earthbucket-media"
      SES_SENDER_EMAIL_ADDRESS      = var.sender_email_address
    }
  }
}

resource "aws_iam_role" "api" {
  name = "${var.namespace}-${var.environment}-${random_id.api.id}-api-lambda-role"

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

resource "aws_iam_role_policy" "api" {
  name = "${var.namespace}-${var.environment}-api-lambda-policy"
  role = aws_iam_role.api.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ],
        "Effect": "Allow",
        "Resource": "*",
        "Condition": {
          "StringEquals": {
              "ses:FromAddress": "${var.sender_email_address}"
          }
        }
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "api_AmazonDynamoDBFullAccess" {
  role       = aws_iam_role.basic_auth.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "api_AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.basic_auth.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "api_CloudFrontFullAccess" {
  role       = aws_iam_role.basic_auth.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}