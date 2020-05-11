data "aws_acm_certificate" "ssl" {
  provider = aws.acm // this is an AWS requirement
  domain   = "www.${var.domain_name}"
  statuses = ["ISSUED"]
  depends_on  = [
    aws_acm_certificate.naked_domain,
    aws_acm_certificate.www_domain
  ]
}

resource "aws_cloudfront_origin_access_identity" "www_origin_access_identity" {
  comment = "www_OAI"
}

resource "aws_cloudfront_distribution" "cdn" {
  depends_on  = [
    aws_acm_certificate.naked_domain,
    aws_acm_certificate.www_domain,
    aws_s3_bucket.www_domain_bucket
  ]

  enabled             = true
  default_root_object = "index.html"
  aliases = [
    "www.${var.domain_name}",
    # var.domain_name
  ]

  origin {
    # domain_name = aws_s3_bucket.www_domain_bucket.website_endpoint
    domain_name = aws_s3_bucket.www_domain_bucket.bucket_regional_domain_name
    origin_id   = "S3-www.${var.domain_name}"

    # custom_origin_config {
    #   http_port                = "80"
    #   https_port               = "443"
    #   #origin_keepalive_timeout = 5
    #   origin_protocol_policy   = "http-only"
    #   origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    # }

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.www_origin_access_identity.cloudfront_access_identity_path
    }
  }  

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.www_domain.arn
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-www.${var.domain_name}"
    compress         = var.enable_gzip

    # Lambda@edge 
    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.folder_index_redirect.qualified_arn
      include_body = false
    }

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }
}

# ---- CloudFront Naked Domain

resource "aws_cloudfront_distribution" "naked_cdn" {
  depends_on  = [
    aws_acm_certificate.naked_domain,
    aws_acm_certificate.www_domain,
    aws_s3_bucket.naked_domain_redirect
  ]
  enabled             = true
  default_root_object = ""
  aliases = [
    var.domain_name
  ]

  origin {
    domain_name = aws_s3_bucket.naked_domain_redirect.website_endpoint
    origin_id   = "S3-${var.domain_name}"

    custom_origin_config {
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.naked_domain.arn
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.domain_name}"
    compress         = var.enable_gzip

    # Lambda@edge 
    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.folder_index_redirect.qualified_arn
      include_body = false
    }

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }
}
