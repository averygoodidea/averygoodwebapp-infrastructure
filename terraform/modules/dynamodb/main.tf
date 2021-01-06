resource "aws_dynamodb_table" "basic_auth" {
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

resource "aws_dynamodb_table" "album_posts" {
  name           = "${var.namespace}-${var.environment}-WaterApiAlbumPostsTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "partitionKey"
  range_key      = "id"

  attribute {
    name = "partitionKey"
    type = "S"
  }

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "admin" {
  name           = "${var.namespace}-${var.environment}-WaterApiAdminsTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "partitionKey"
  range_key      = "email"

  attribute {
    name = "partitionKey"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }
}