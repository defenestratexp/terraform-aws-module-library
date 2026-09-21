# ------------------------------------------------------------------------------
# S3 BUCKET MODULE
# Creates an S3 bucket with encryption, versioning, and lifecycle policies
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "s3-bucket"
  }

  tags = merge(local.default_tags, var.tags)
}

# ------------------------------------------------------------------------------
# S3 BUCKET
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "main" {
  bucket        = var.name
  force_destroy = var.force_destroy

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# OWNERSHIP CONTROLS
# ------------------------------------------------------------------------------

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    object_ownership = var.object_ownership
  }
}

# ------------------------------------------------------------------------------
# PUBLIC ACCESS BLOCK
# ------------------------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = var.block_public_access ? true : var.block_public_acls
  block_public_policy     = var.block_public_access ? true : var.block_public_policy
  ignore_public_acls      = var.block_public_access ? true : var.ignore_public_acls
  restrict_public_buckets = var.block_public_access ? true : var.restrict_public_buckets
}

# ------------------------------------------------------------------------------
# ENCRYPTION
# ------------------------------------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.encryption_algorithm
      kms_master_key_id = var.encryption_algorithm == "aws:kms" ? var.kms_key_arn : null
    }
    bucket_key_enabled = var.encryption_algorithm == "aws:kms" ? var.bucket_key_enabled : null
  }
}

# ------------------------------------------------------------------------------
# VERSIONING
# ------------------------------------------------------------------------------

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# ------------------------------------------------------------------------------
# LIFECYCLE RULES
# ------------------------------------------------------------------------------

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.main.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "filter" {
        for_each = rule.value.prefix != "" || length(rule.value.tags) > 0 ? [1] : []
        content {
          prefix = rule.value.prefix
          dynamic "tag" {
            for_each = rule.value.tags
            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration_days != null ? [1] : []
        content {
          days = rule.value.expiration_days
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration_days != null ? [1] : []
        content {
          noncurrent_days = rule.value.noncurrent_version_expiration_days
        }
      }

      dynamic "transition" {
        for_each = rule.value.transition
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transition
        content {
          noncurrent_days = noncurrent_version_transition.value.noncurrent_days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload_days != null ? [1] : []
        content {
          days_after_initiation = rule.value.abort_incomplete_multipart_upload_days
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.main]
}

# ------------------------------------------------------------------------------
# LOGGING
# ------------------------------------------------------------------------------

resource "aws_s3_bucket_logging" "main" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.main.id

  target_bucket = var.logging_target_bucket
  target_prefix = var.logging_target_prefix
}

# ------------------------------------------------------------------------------
# CORS
# ------------------------------------------------------------------------------

resource "aws_s3_bucket_cors_configuration" "main" {
  count  = length(var.cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.main.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

# ------------------------------------------------------------------------------
# WEBSITE CONFIGURATION
# ------------------------------------------------------------------------------

resource "aws_s3_bucket_website_configuration" "main" {
  count  = var.enable_website ? 1 : 0
  bucket = aws_s3_bucket.main.id

  index_document {
    suffix = var.website_index_document
  }

  error_document {
    key = var.website_error_document
  }
}
