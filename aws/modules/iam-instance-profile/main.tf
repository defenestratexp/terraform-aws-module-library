# ------------------------------------------------------------------------------
# IAM INSTANCE PROFILE MODULE
# Creates an instance profile with an IAM role for EC2
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "iam-instance-profile"
  }

  tags = merge(local.default_tags, var.tags)

  # Determine the role name to use
  role_name = var.create_role ? aws_iam_role.main[0].name : regex("role/(.+)$", var.role_arn)[0]
}

# ------------------------------------------------------------------------------
# ASSUME ROLE POLICY
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "assume_role" {
  count = var.create_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = var.trusted_services
    }
  }
}

# ------------------------------------------------------------------------------
# IAM ROLE
# ------------------------------------------------------------------------------

resource "aws_iam_role" "main" {
  count = var.create_role ? 1 : 0

  name        = var.name
  path        = var.path
  description = "IAM role for instance profile ${var.name}"

  assume_role_policy   = data.aws_iam_policy_document.assume_role[0].json
  permissions_boundary = var.permissions_boundary != "" ? var.permissions_boundary : null

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# MANAGED POLICY ATTACHMENTS
# ------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = var.create_role ? toset(var.managed_policy_arns) : toset([])

  role       = aws_iam_role.main[0].name
  policy_arn = each.value
}

# ------------------------------------------------------------------------------
# INLINE POLICIES
# ------------------------------------------------------------------------------

resource "aws_iam_role_policy" "inline" {
  for_each = var.create_role ? var.inline_policies : {}

  name   = each.key
  role   = aws_iam_role.main[0].name
  policy = each.value
}

# ------------------------------------------------------------------------------
# INSTANCE PROFILE
# ------------------------------------------------------------------------------

resource "aws_iam_instance_profile" "main" {
  name = var.name
  path = var.path
  role = local.role_name

  tags = merge(local.tags, {
    Name = var.name
  })
}
