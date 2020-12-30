output "aircdn_distribution_id" {
  value = aws_cloudfront_distribution.aircdn.id
}

output "aircdn_distribution_arn" {
  value = aws_cloudfront_distribution.aircdn.arn
}

output "aircdn_distribution_domain" {
  value = aws_cloudfront_distribution.aircdn.domain_name
}

output "alias_distribution" {
  value = aws_cloudfront_distribution.aircdn
}

output "redirect_aircdn_distribution_id" {
  value = aws_cloudfront_distribution.redirect.id
}

output "redirect_aircdn_distribution_arn" {
  value = aws_cloudfront_distribution.redirect.arn
}

output "redirect_aircdn_distribution_domain" {
  value = aws_cloudfront_distribution.redirect.domain_name
}


output "redirect_distribution" {
  value = aws_cloudfront_distribution.redirect
}