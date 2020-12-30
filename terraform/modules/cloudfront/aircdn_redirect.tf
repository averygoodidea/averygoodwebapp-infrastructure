resource "aws_s3_bucket" "redirect" {
  bucket = "www.${var.domain_name}"
  acl    = "public-read"
  website {
    redirect_all_requests_to = var.domain_name
  }
}

resource "aws_cloudfront_distribution" "redirect" {
  enabled = true
  comment = "${var.namespace} ${var.environment} AirCdnRedirect for AirCdn www redirect"
  aliases = ["www.${var.domain_name}"]

  origin {
    domain_name = aws_s3_bucket.redirect.website_endpoint
    origin_id   = "aircdn-redirect"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "Referer"
      value = "https://${var.domain_name}/"
    }
  }

  default_cache_behavior {
    target_origin_id       = "aircdn-redirect"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.certificate_arn
    ssl_support_method  = "sni-only"
  }

  price_class = "PriceClass_100"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  retain_on_delete = true
}