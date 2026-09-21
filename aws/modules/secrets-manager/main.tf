# ------------------------------------------------------------------------------
# SECRETS MANAGER MODULE
# Creates a Secrets Manager secret with optional rotation and replication
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "secrets-manager"
  }

  tags = merge(local.default_tags, var.tags)

  # Determine if secret value is provided
  has_secret_value = var.secret_string != "" || var.secret_binary != ""
}

# ------------------------------------------------------------------------------
# SECRET
# ------------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "main" {
  name        = var.name
  description = var.description != "" ? var.description : "Managed secret ${var.name}"

  kms_key_id = var.kms_key_id != "" ? var.kms_key_id : null

  recovery_window_in_days = var.recovery_window_in_days

  force_overwrite_replica_secret = var.force_overwrite_replica_secret

  dynamic "replica" {
    for_each = var.replica_regions
    content {
      region     = replica.value.region
      kms_key_id = replica.value.kms_key_id
    }
  }

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# SECRET VERSION
# ------------------------------------------------------------------------------

# lifecycle.ignore_changes has to be a static list, so the "Terraform sets the
# value once and then leaves it alone" behaviour lives on a second resource.
resource "aws_secretsmanager_secret_version" "main" {
  count = local.has_secret_value && !var.ignore_secret_changes ? 1 : 0

  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = var.secret_string != "" ? var.secret_string : null
  secret_binary = var.secret_binary != "" ? var.secret_binary : null
}

resource "aws_secretsmanager_secret_version" "unmanaged" {
  count = local.has_secret_value && var.ignore_secret_changes ? 1 : 0

  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = var.secret_string != "" ? var.secret_string : null
  secret_binary = var.secret_binary != "" ? var.secret_binary : null

  lifecycle {
    ignore_changes = [secret_string, secret_binary]
  }
}

locals {
  secret_version = one(concat(aws_secretsmanager_secret_version.main, aws_secretsmanager_secret_version.unmanaged))
}

# ------------------------------------------------------------------------------
# SECRET POLICY
# ------------------------------------------------------------------------------

resource "aws_secretsmanager_secret_policy" "main" {
  count = var.policy != "" ? 1 : 0

  secret_arn = aws_secretsmanager_secret.main.arn
  policy     = var.policy
}

# ------------------------------------------------------------------------------
# SECRET ROTATION
# ------------------------------------------------------------------------------

resource "aws_secretsmanager_secret_rotation" "main" {
  count = var.enable_rotation ? 1 : 0

  secret_id           = aws_secretsmanager_secret.main.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation_schedule_expression == "" ? var.rotation_days : null
    schedule_expression      = var.rotation_schedule_expression != "" ? var.rotation_schedule_expression : null
  }
}
