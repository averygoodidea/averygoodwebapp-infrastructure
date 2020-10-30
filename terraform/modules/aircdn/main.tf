resource "aws_cloudfront_distribution" "aircdn" {
    origin {
        domain_name = "${var.namspace}-${var.environment}-earthbucket-app.s3-website-${var.region}.amazonaws.com"
        origin_id = earthbucket
        custom_origin_config {
            http_port = 80
            https_port = 443
            origin_protocol_policy = http-only
        }
        custom_header {
            name = Referer
            value = "https://${var.domain_name}/"
        }
    }
    origin {
        domain_name = "${var.namspace}-${var.environment}-earthbucket-docs.s3-website-${var.region}.amazonaws.com"
        origin_id = earthbucket-docs
        custom_origin_config {
            http_port = 80
            https_port = 443
            origin_protocol_policy = http-only
        }
    }
    origin {
        domain_name = "${var.namspace}-${var.environment}-waterapi-docs.s3-website-${var.region}.amazonaws.com"
        origin_id = waterapi-docs
        custom_origin_config {
            http_port = 80
            https_port = 443
            origin_protocol_policy = http-only
        }
    }
}