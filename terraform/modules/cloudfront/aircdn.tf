resource "aws_cloudfront_distribution" "aircdn" {
  enabled = true
  comment = "${var.namespace} ${var.environment} AirCdn for EarthBucket site and WaterApi api"
  default_root_object = "index.html"
  aliases = [ var.domain_name ]

  origin {
    domain_name = "${var.namespace}-${var.environment}-earthbucket-app.s3-website-${var.region}.amazonaws.com"
    origin_id   = "earthbucket"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1.2"]
    }
    custom_header {
      name  = "Referer"
      value = "https://${var.domain_name}/"
    }
  }

  origin {
    domain_name = "${var.namespace}-${var.environment}-earthbucket-docs.s3-website-${var.region}.amazonaws.com"
    origin_id   = "earthbucket-docs"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = "${var.namespace}-${var.environment}-waterapi-docs.s3-website-${var.region}.amazonaws.com"
    origin_id   = "waterapi-docs"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1.2"]
    }
  }

  # Cache behavior with precedence 0
  # ordered_cache_behavior {
  #   path_pattern = "/api/1/admin/magic-link"
  #   allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  #   cached_methods   = ["GET", "HEAD", "OPTIONS"]
  #   target_origin_id = "waterapi-unauthenticated-api"

  #   forwarded_values {
  #     query_string = true
  #     headers      = ["Accept", "Referer", "Authorization", "Content-Type"]

  #     cookies {
  #       forward = "none"
  #     }
  #   }

  #   min_ttl                = 0
  #   max_ttl                = 31536000
  #   compress               = true
  #   viewer_protocol_policy = "https-only"
  # }

  # # Cache behavior with precedence 1
  # ordered_cache_behavior {
  #   path_pattern = "/api/1/admin/hash"
  #   allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  #   cached_methods   = ["GET", "HEAD", "OPTIONS"]
  #   target_origin_id = "waterapi-unauthenticated-api"

  #   forwarded_values {
  #     query_string = true
  #     headers      = ["Accept", "Referer", "Authorization", "Content-Type"]

  #     cookies {
  #       forward = "none"
  #     }
  #   }

  #   min_ttl                = 0
  #   max_ttl                = 31536000
  #   compress               = true
  #   viewer_protocol_policy = "https-only"
  # }

  # # Cache behavior with precedence 2
  # ordered_cache_behavior {
  #   path_pattern = "/api/1/admin/*"
  #   allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  #   cached_methods   = ["GET", "HEAD", "OPTIONS"]
  #   target_origin_id = "waterapi-authenticated-api"

  #   forwarded_values {
  #     query_string = true
  #     headers      = ["Accept", "Referer", "Authorization", "Content-Type"]

  #     cookies {
  #       forward = "none"
  #     }
  #   }

  #   min_ttl                = 0
  #   max_ttl                = 31536000
  #   compress               = true
  #   viewer_protocol_policy = "https-only"
  # }

  # # Cache behavior with precedence 3
  # ordered_cache_behavior {
  #   path_pattern = "/api/1/*"
  #   allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  #   cached_methods   = ["GET", "HEAD", "OPTIONS"]
  #   target_origin_id = "waterapi-unauthenticated-api"

  #   forwarded_values {
  #     query_string = true
  #     headers      = ["Accept", "Referer", "Authorization", "Content-Type"]

  #     cookies {
  #       forward = "none"
  #     }
  #   }

  #   min_ttl                = 0
  #   max_ttl                = 31536000
  #   compress               = true
  #   viewer_protocol_policy = "https-only"
  # }

  # Cache behavior with precedence 4
  ordered_cache_behavior {
    path_pattern = "/api/1/docs*"
    target_origin_id = "earthbucket-docs"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    default_ttl = 31536000
    viewer_protocol_policy = "redirect-to-https"
  }

  default_cache_behavior {
    target_origin_id = "earthbucket"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    compress = true

    default_ttl = 31536000 #365 days in seconds

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
      acm_certificate_arn = var.certificate_arn
      ssl_support_method = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}