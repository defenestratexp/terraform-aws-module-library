# ------------------------------------------------------------------------------
# ROUTE53 ZONE MODULE
# Creates a Route53 hosted zone (public or private)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "route53-zone"
  }

  tags = merge(local.default_tags, var.tags)
}

# ------------------------------------------------------------------------------
# HOSTED ZONE
# ------------------------------------------------------------------------------

resource "aws_route53_zone" "main" {
  name    = var.name
  comment = var.comment != "" ? var.comment : (var.is_private ? "Private zone for ${var.name}" : "Public zone for ${var.name}")

  delegation_set_id = var.delegation_set_id != "" ? var.delegation_set_id : null

  # VPC associations for private zones
  dynamic "vpc" {
    for_each = var.is_private ? var.vpc_associations : []
    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = vpc.value.vpc_region
    }
  }

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# DNSSEC
# ------------------------------------------------------------------------------

resource "aws_route53_key_signing_key" "main" {
  count = var.enable_dnssec && !var.is_private ? 1 : 0

  hosted_zone_id             = aws_route53_zone.main.id
  key_management_service_arn = aws_kms_key.dnssec[0].arn
  name                       = "${replace(var.name, ".", "-")}-ksk"
}

resource "aws_kms_key" "dnssec" {
  count = var.enable_dnssec && !var.is_private ? 1 : 0

  customer_master_key_spec = "ECC_NIST_P256"
  deletion_window_in_days  = 7
  key_usage                = "SIGN_VERIFY"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowRoute53DNSSEC"
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:route53:::hostedzone/*"
          }
        }
      },
      {
        Sid    = "AllowRoute53CreateGrant"
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Action   = "kms:CreateGrant"
        Resource = "*"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = "true"
          }
        }
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "${var.name}-dnssec"
  })
}

resource "aws_route53_hosted_zone_dnssec" "main" {
  count = var.enable_dnssec && !var.is_private ? 1 : 0

  hosted_zone_id = aws_route53_zone.main.id

  depends_on = [aws_route53_key_signing_key.main]
}

# ------------------------------------------------------------------------------
# QUERY LOGGING
# ------------------------------------------------------------------------------

resource "aws_route53_query_log" "main" {
  count = var.enable_query_logging && var.query_log_group_arn != "" ? 1 : 0

  cloudwatch_log_group_arn = var.query_log_group_arn
  zone_id                  = aws_route53_zone.main.zone_id
}

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
