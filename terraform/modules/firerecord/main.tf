resource "aws_acm_certificate" "firerecord" {
  domain_name       = var.domain_name
  validation_method = "DNS"
}
data "aws_route53_zone" "firerecord" {
  name         = var.firerecord_zone
  private_zone = false
}

resource "aws_route53_record" "dns_challlenge" {
  zone_id = data.aws_route53_zone.firerecord.zone_id
  for_each = {
    for dvo in aws_acm_certificate.firerecord.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
}

resource "aws_acm_certificate_validation" "firerecord" {
  certificate_arn         = aws_acm_certificate.firerecord.arn
  validation_record_fqdns = [for record in aws_route53_record.dns_challlenge : record.fqdn]
}

# resource "aws_route53_record" "firerecord_alias" {
#   zone_id = data.aws_route53_zone.firerecord.zone_id
#   name    = var.domain_name
#   type    = "A"

#   alias {
#     name                   = var.aircdn_redirect_domain_name
#     zone_id                = var.aircdn_hosted_zone
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_record" "firerecord_alias_redirect" {
#   zone_id = data.aws_route53_zone.firerecord_zone.zone_id
#   name    = var.domain_name_redirect
#   type    = "A"

#   alias {
#     name                   = var.aircdn_redirect_domain_name
#     zone_id                = var.aircdn_hosted_zone
#     evaluate_target_health = true
#   }
# }