data "aws_route53_zone" "main" {
  name         = var.firerecord_zone
  private_zone = false
}

resource "aws_route53_record" "alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alias_distribution.domain_name
    zone_id                = var.alias_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "redirect" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.redirect_distribution.domain_name
    zone_id                = var.redirect_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}