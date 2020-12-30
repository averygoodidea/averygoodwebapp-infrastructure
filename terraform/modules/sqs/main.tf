resource "random_string" "sqs" {
  length  = 4
  special = false
}

resource "aws_sqs_queue" "app" {
  name                       = "${var.namespace}-${var.environment}-EarthBucketSQS-${random_string.sqs.result}"
  receive_wait_time_seconds  = 0 # keep this number at 0
  visibility_timeout_seconds = 14400
  message_retention_seconds  = 60
}

resource "aws_sqs_queue_policy" "app" {
  queue_url = aws_sqs_queue.app.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": [
        "sqs:SendMessage",
        "sqs:ReceiveMessage"
      ],
      "Resource": "${aws_sqs_queue.app.arn}",
      "Condition": {
          "ArnLike": {
              "aws:SourceArn": " arn:aws:s3:::*"
          }
      }
    }
  ]
}
POLICY
}