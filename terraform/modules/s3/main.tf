## APP

resource "aws_s3_bucket" "app" {
  bucket = "${var.namespace}-${var.environment}-earthbucket-app"
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}


# resource "aws_s3_bucket_notification" "app" {
#   bucket = aws_s3_bucket.app.id

#   queue {
#     queue_arn     = var.queue_arn
#     events        = ["s3:ObjectCreated:Put"]
#     filter_suffix = ".log"
#   }
# }

resource "aws_s3_bucket_policy" "app" {
  bucket = aws_s3_bucket.app.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "Application static site bucket policy",
  "Statement": [
    {
      "Sid": "AddS3Perm",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.app.arn}",
        "${aws_s3_bucket.app.arn}/*"
      ],
      "Condition": {
          "StringLike": {
              "aws:Referer": "https://${var.domain_name}"
          }
      }
    }
  ]
}
POLICY
}

## MEDIA

resource "aws_s3_bucket" "media" {
  bucket = "${var.namespace}-${var.environment}-earthbucket-media"
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  cors_rule {
    allowed_headers = ["Content-Type"]
    allowed_methods = ["GET", "PUT", "DELETE", "HEAD"]
    allowed_origins = ["https:/${var.domain_name}"]
  }
}

resource "aws_s3_bucket_policy" "media" {
  bucket = aws_s3_bucket.media.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "Media static site bucket policy",
  "Statement": [
    {
      "Sid": "AllowPublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject"
        ],
      "Resource": "${aws_s3_bucket.media.arn}/*",
      "Condition": {
         "StringLike": {"aws:Referer": "https://${var.domain_name}"}
      }
    }
  ]
}
POLICY
}

## DOCS

resource "aws_s3_bucket" "doc" {
  bucket = "${var.namespace}-${var.environment}-earthbucket-docs"
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_policy" "doc" {
  bucket = aws_s3_bucket.doc.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "Docs static site bucket policy",
  "Statement": [
    {
      "Sid": "AddPerm",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
          "s3:GetObject",
          "s3:PutObject"
       ],
      "Resource": "${aws_s3_bucket.doc.arn}/*",
      "Condition": {
         "StringLike": {"aws:Referer": "https://${var.domain_name}/*"}
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket" "api" {
  bucket = "${var.namespace}-${var.environment}-waterapi-docs"
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_policy" "api" {
  bucket = aws_s3_bucket.api.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "Docs static site bucket policy",
  "Statement": [
    {
      "Sid": "AddPerm",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
          "s3:GetObject",
          "s3:PutObject"
       ],
      "Resource": "${aws_s3_bucket.api.arn}/*",
      "Condition": {
         "StringLike": {"aws:Referer": "https://${var.domain_name}/*"}
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket" "waterapi_lambda_deployment_bucket" {
  bucket = "${var.namespace}-${var.environment}-waterapi-api"
}