# --- Create naked (eit-demo.com) certificate
resource "aws_acm_certificate" "naked_domain" {
  provider                  = aws.acm
  domain_name               = var.domain_name
  subject_alternative_names = [var.domain_name]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true

    # Workaround to avoid terraform of reissuing the cert, add cnames and validation
    ignore_changes = [
      subject_alternative_names
    ]
  }
}

# --- Create www (weit-demo.com) certificate
resource "aws_acm_certificate" "www_domain" {
  provider                  = aws.acm
  domain_name               = "www.${var.domain_name}"
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true

    # Workaround to avoid terraform of reissuing the cert, add cnames and validation
    ignore_changes = [
      subject_alternative_names
    ]
  }
}

# --- Get Zone ID of the domain
data "aws_route53_zone" "default" {
  name = var.domain_name
}

# --- Add naked CNAME onto Route53
resource "aws_route53_record" "cname_naked_domain_validation" {
  zone_id = data.aws_route53_zone.default.zone_id

  name    = aws_acm_certificate.naked_domain.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.naked_domain.domain_validation_options.0.resource_record_type
  records = [aws_acm_certificate.naked_domain.domain_validation_options.0.resource_record_value]
  ttl     = "60"

  depends_on = [
    aws_acm_certificate.naked_domain
  ]
}

# --- Add www CNAME onto Route53
resource "aws_route53_record" "cname_www_domain_validation" {
  zone_id = data.aws_route53_zone.default.zone_id

  name    = aws_acm_certificate.www_domain.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.www_domain.domain_validation_options.0.resource_record_type
  records = [aws_acm_certificate.www_domain.domain_validation_options.0.resource_record_value]
  ttl     = "60"

  depends_on = [
    aws_acm_certificate.www_domain
  ]
}

# --- Validate naked certificate
resource "aws_acm_certificate_validation" "naked_domain_validation" {
  provider        = aws.acm
  certificate_arn = aws_acm_certificate.naked_domain.arn

  validation_record_fqdns = [
    aws_route53_record.cname_naked_domain_validation.fqdn
  ]

  depends_on = [
    aws_route53_record.cname_naked_domain_validation
  ]

}

# --- Validate www certificate
resource "aws_acm_certificate_validation" "www_domain_validation" {
  provider        = aws.acm
  certificate_arn = aws_acm_certificate.www_domain.arn

  validation_record_fqdns = [
    aws_route53_record.cname_www_domain_validation.fqdn
  ]

  depends_on = [
    aws_route53_record.cname_www_domain_validation
  ]
}