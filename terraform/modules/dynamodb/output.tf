output "basic_auth_table" {
  value = aws_dynamodb_table.basic_auth.id
}

output "basic_auth_table_url" {
  value = "https://console.aws.amazon.com/dynamodb/home?region=${var.region}#tables:selected=${aws_dynamodb_table.basic_auth.id};tab=items"
}

output "album_posts_table" {
  value = aws_dynamodb_table.album_posts.id
}

output "album_posts_table_url" {
  value = "https://console.aws.amazon.com/dynamodb/home?region=${var.region}#tables:selected=${aws_dynamodb_table.album_posts.id};tab=items"
}

output "admin_table" {
  value = aws_dynamodb_table.admin.id
}

output "admin_table_url" {
  value = "https://console.aws.amazon.com/dynamodb/home?region=${var.region}#tables:selected=${aws_dynamodb_table.admin.id};tab=items"
}