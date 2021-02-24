resource "random_id" "table" {
  byte_length = 4
}

resource "aws_dynamodb_table" "basic_auth" {
  name           = "${var.namespace}-${var.environment}-${random_id.table.id}-EarthBucketBasicAuthTable"
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
  name           = "${var.namespace}-${var.environment}-${random_id.table.id}-WaterApiAlbumPostsTable"
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
  name           = "${var.namespace}-${var.environment}-${random_id.table.id}-WaterApiAdminsTable"
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