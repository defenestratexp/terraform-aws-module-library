# ------------------------------------------------------------------------------
# IAM USER MODULE
# Creates an IAM user with optional access keys and login profile
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "iam-user"
  }

  tags = merge(local.default_tags, var.tags)
}

# ------------------------------------------------------------------------------
# IAM USER
# ------------------------------------------------------------------------------

resource "aws_iam_user" "main" {
  name = var.name
  path = var.path

  permissions_boundary = var.permissions_boundary != "" ? var.permissions_boundary : null
  force_destroy        = var.force_destroy

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# ACCESS KEY
# ------------------------------------------------------------------------------

resource "aws_iam_access_key" "main" {
  count = var.create_access_key ? 1 : 0

  user    = aws_iam_user.main.name
  status  = var.access_key_status
  pgp_key = var.pgp_key != "" ? var.pgp_key : null
}

# ------------------------------------------------------------------------------
# LOGIN PROFILE
# ------------------------------------------------------------------------------

resource "aws_iam_user_login_profile" "main" {
  count = var.create_login_profile ? 1 : 0

  user                    = aws_iam_user.main.name
  password_length         = var.password_length
  password_reset_required = var.password_reset_required
  pgp_key                 = var.pgp_key != "" ? var.pgp_key : null

  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required
    ]
  }
}

# ------------------------------------------------------------------------------
# MANAGED POLICY ATTACHMENTS
# ------------------------------------------------------------------------------

resource "aws_iam_user_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  user       = aws_iam_user.main.name
  policy_arn = each.value
}

# ------------------------------------------------------------------------------
# INLINE POLICIES
# ------------------------------------------------------------------------------

resource "aws_iam_user_policy" "inline" {
  for_each = var.inline_policies

  name   = each.key
  user   = aws_iam_user.main.name
  policy = each.value
}

# ------------------------------------------------------------------------------
# GROUP MEMBERSHIPS
# ------------------------------------------------------------------------------

resource "aws_iam_user_group_membership" "main" {
  count = length(var.groups) > 0 ? 1 : 0

  user   = aws_iam_user.main.name
  groups = var.groups
}
