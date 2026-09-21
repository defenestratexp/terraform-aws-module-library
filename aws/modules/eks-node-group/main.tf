# ------------------------------------------------------------------------------
# EKS NODE GROUP MODULE
# Creates a managed node group for an EKS cluster
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_partition" "current" {}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "eks-node-group"
  }

  tags = merge(local.default_tags, var.tags)

  node_role_arn = var.node_role_arn != null ? var.node_role_arn : (var.create_node_role ? aws_iam_role.node[0].arn : null)
}

# ------------------------------------------------------------------------------
# NODE IAM ROLE
# ------------------------------------------------------------------------------

resource "aws_iam_role" "node" {
  count = var.create_node_role ? 1 : 0

  name = "${var.cluster_name}-${var.name}-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "${var.cluster_name}-${var.name}-node"
  })
}

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = var.create_node_role ? toset([
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]) : toset([])

  role       = aws_iam_role.node[0].name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "node_additional" {
  for_each = var.create_node_role ? var.node_role_policies : {}

  role       = aws_iam_role.node[0].name
  policy_arn = each.value
}

# ------------------------------------------------------------------------------
# EKS NODE GROUP
# ------------------------------------------------------------------------------

resource "aws_eks_node_group" "main" {
  cluster_name    = var.cluster_name
  node_group_name = var.name
  node_role_arn   = local.node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  update_config {
    max_unavailable            = var.max_unavailable_percentage == null ? var.max_unavailable : null
    max_unavailable_percentage = var.max_unavailable_percentage
  }

  # Instance configuration (not used with custom launch template)
  instance_types  = var.use_custom_launch_template ? null : var.instance_types
  capacity_type   = var.capacity_type
  disk_size       = var.use_custom_launch_template ? null : var.disk_size
  ami_type        = var.use_custom_launch_template ? null : var.ami_type
  release_version = var.release_version

  # Custom launch template
  dynamic "launch_template" {
    for_each = var.use_custom_launch_template && var.launch_template_id != null ? [1] : []
    content {
      id      = var.launch_template_id
      version = var.launch_template_version
    }
  }

  # Remote access
  dynamic "remote_access" {
    for_each = var.remote_access != null ? [var.remote_access] : []
    content {
      ec2_ssh_key               = remote_access.value.ec2_ssh_key
      source_security_group_ids = remote_access.value.source_security_group_ids
    }
  }

  # Labels
  labels = var.labels

  # Taints
  dynamic "taint" {
    for_each = var.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  tags = merge(local.tags, {
    Name = "${var.cluster_name}-${var.name}"
  })

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size, # Allow external scaling
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policies,
    aws_iam_role_policy_attachment.node_additional,
  ]
}
