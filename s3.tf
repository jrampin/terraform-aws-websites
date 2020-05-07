resource "aws_s3_bucket" "www_domain_bucket" {
  bucket = "www.${var.domain_name}"
  acl    = "private"

  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket" "naked_domain_redirect" {
  bucket = var.domain_name

  force_destroy = true

  website {
    redirect_all_requests_to = aws_s3_bucket.www_domain_bucket.id
  }
}

resource "aws_route53_record" "www_alias_record" {
  zone_id = data.aws_route53_zone.default.zone_id

  name = "www.${var.domain_name}"
  type = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "naked_alias_record" {
  zone_id = data.aws_route53_zone.default.zone_id

  name = var.domain_name
  type = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
