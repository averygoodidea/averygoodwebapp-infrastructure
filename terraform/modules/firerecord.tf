data "aws_route53_zone" "firerecord_zone" {
  name         = var.firerecord_zone
  private_zone = true
}

resource "aws_route53_record" "firerecord_alias" {
  zone_id = data.aws_route53_zone.firerecord_zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.aircdn_domain_name
    zone_id                = var.aircdn_hosted_zone
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "firerecord_alias_redirect" {
  zone_id = data.aws_route53_zone.firerecord_zone.zone_id
  name    = var.domain_name_redirect
  type    = "A"

  alias {
    name                   = var.aircdn_redirect_domain_name
    zone_id                = var.aircdn_hosted_zone
    evaluate_target_health = true
  }
}