output "earthbucket_app_bucket_id" {
  value = aws_s3_bucket.app.id
}

output "earthbucket_app_bucket_arn" {
  value = aws_s3_bucket.app.arn
}

output "earthbucket_app_bucket_endpoint" {
  value = aws_s3_bucket.app.website_endpoint
}

output "earthbucket_app_bucket_domain" {
  value = aws_s3_bucket.app.website_domain
}

output "earthbucket_media_bucket_id" {
  value = aws_s3_bucket.media.id
}

output "earthbucket_media_bucket_arn" {
  value = aws_s3_bucket.media.arn
}

output "earthbucket_media_bucket_endpoint" {
  value = aws_s3_bucket.media.website_endpoint
}

output "earthbucket_media_bucket_domain" {
  value = aws_s3_bucket.media.website_domain
}

output "earthbucket_doc_bucket_id" {
  value = aws_s3_bucket.doc.id
}

output "earthbucket_doc_bucket_arn" {
  value = aws_s3_bucket.doc.arn
}

output "earthbucket_doc_bucket_endpoint" {
  value = aws_s3_bucket.doc.website_endpoint
}

output "earthbucket_doc_bucket_domain" {
  value = aws_s3_bucket.doc.website_domain
}