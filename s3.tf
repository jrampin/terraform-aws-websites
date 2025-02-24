# --- Add www s3 bucket
resource "aws_s3_bucket" "www_domain_bucket" {
  bucket = "www.${var.domain_name}"
  acl    = "private"

  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

# --- Get data/policy that allows CDN access to www bucket
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.www_domain_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.www_origin_access_identity.iam_arn]
    }
  }
}

# --- Add policy that allows CDN access to www bucket
resource "aws_s3_bucket_policy" "allow_cdn_www_bucket" {
  bucket = aws_s3_bucket.www_domain_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

# --- Add redirect bucket
resource "aws_s3_bucket" "naked_domain_redirect" {
  bucket = var.domain_name  

  force_destroy = true

  website {
    redirect_all_requests_to = aws_s3_bucket.www_domain_bucket.id
  }
}

# --- Add alias www.eit-demo.com to CDN
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

# --- Add alias eit-demo.com to CDN
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