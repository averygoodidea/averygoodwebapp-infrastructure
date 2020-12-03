# output "firerecord_alias" {
#     value = aws_route53_record.firerecord_alias.fqdn
# }

# output "firerecord_alias_redirect" {
#     value = aws_route53_record.firerecord_alias_redirect.fqdn
# }

output "waterapi_certificate_arn" {
    value = aws_acm_certificate.firerecord.arn
}