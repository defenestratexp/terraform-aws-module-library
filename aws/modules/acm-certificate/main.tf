# ------------------------------------------------------------------------------
# ACM CERTIFICATE MODULE
# Creates an ACM SSL/TLS certificate with optional DNS validation
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "acm-certificate"
  }

  tags = merge(local.default_tags, var.tags)

  # Determine if we should create Route53 records
  create_dns_records = var.validation_method == "DNS" && var.create_route53_records && var.route53_zone_id != ""
}

# ------------------------------------------------------------------------------
# ACM CERTIFICATE
# ------------------------------------------------------------------------------

resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method
  key_algorithm             = var.key_algorithm

  options {
    certificate_transparency_logging_preference = var.certificate_transparency_logging_preference
  }

  tags = merge(local.tags, {
    Name = var.domain_name
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# ROUTE53 VALIDATION RECORDS
# ------------------------------------------------------------------------------

resource "aws_route53_record" "validation" {
  for_each = local.create_dns_records ? {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

# ------------------------------------------------------------------------------
# CERTIFICATE VALIDATION
# ------------------------------------------------------------------------------

resource "aws_acm_certificate_validation" "main" {
  count = var.wait_for_validation ? 1 : 0

  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = local.create_dns_records ? [for record in aws_route53_record.validation : record.fqdn] : null

  timeouts {
    create = var.validation_timeout
  }
}
