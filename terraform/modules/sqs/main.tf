resource "random_uuid" "sqs" {}

resource "aws_sqs_queue" "app" {
  name                              = "${var.namespace}-${var.environment}-EarthBucketSQS"
  kms_master_key_id                 = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300
  receive_wait_time_seconds         = 0 # keep this number at 0
  visibility_timeout_seconds        = 14400
  message_retention_seconds         = 60
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "sqs:SendMessage",
        "sqs:ReceiveMessage"
      ],
      "Resource": "arn:aws:sqs:*:*:${var.namespace}-${var.environment}-${random_uuid.sqs.result}"
    }
  ]
}
POLICY
}