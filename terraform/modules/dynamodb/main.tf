resource "aws_dynamodb_table" "main" {
  name           = "${var.namespace}-${var.environment}-EarthBucketBasicAuthTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "partitionKey"
  range_key      = "authUser"

  attribute {
    name = "partitionKey"
    type = "S"
  }

  attribute {
    name = "authUser"
    type = "S"
  }
}