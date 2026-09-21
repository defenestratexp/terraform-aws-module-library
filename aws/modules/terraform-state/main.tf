# ------------------------------------------------------------------------------
# TERRAFORM STATE BACKEND RESOURCES
# Creates S3 bucket and DynamoDB table for Terraform state management
# ------------------------------------------------------------------------------

locals {
  bucket_name = "${var.name}-${var.bucket_suffix}"
  table_name  = "${var.name}-${var.table_suffix}"

  default_tags = {
    ManagedBy = "terraform"
    Module    = "terraform-state"
    Purpose   = "terraform-state-backend"
  }

  tags = merge(local.default_tags, var.tags)
}

# ------------------------------------------------------------------------------
# S3 BUCKET FOR STATE STORAGE
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "state" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  tags = merge(local.tags, {
    Name = local.bucket_name
  })

  lifecycle {
    prevent_destroy = false # Controlled by force_destroy variable
  }
}

# Versioning configuration
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn != "" ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_arn != "" ? var.kms_key_arn : null
    }
    bucket_key_enabled = var.kms_key_arn != "" ? true : false
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle rules for noncurrent version expiration
resource "aws_s3_bucket_lifecycle_configuration" "state" {
  count  = var.enable_versioning && var.noncurrent_version_expiration_days > 0 ? 1 : 0
  bucket = aws_s3_bucket.state.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }

    # Clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Bucket policy to enforce SSL/TLS
resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.state.arn,
          "${aws_s3_bucket.state.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.state]
}

# ------------------------------------------------------------------------------
# DYNAMODB TABLE FOR STATE LOCKING
# ------------------------------------------------------------------------------

resource "aws_dynamodb_table" "lock" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # Enable point-in-time recovery for the lock table
  point_in_time_recovery {
    enabled = true
  }

  tags = merge(local.tags, {
    Name = local.table_name
  })
}
