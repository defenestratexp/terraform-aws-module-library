# ------------------------------------------------------------------------------
# EKS CLUSTER MODULE
# Creates an EKS cluster with IAM roles, OIDC provider, and add-ons
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "eks-cluster"
  }

  tags = merge(local.default_tags, var.tags)

  cluster_role_arn = var.cluster_role_arn != null ? var.cluster_role_arn : (var.create_cluster_role ? aws_iam_role.cluster[0].arn : null)

  # Default add-ons
  default_addons = var.enable_default_addons ? {
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
  } : {}

  cluster_addons = merge(local.default_addons, var.cluster_addons)
}

# ------------------------------------------------------------------------------
# CLUSTER IAM ROLE
# ------------------------------------------------------------------------------

resource "aws_iam_role" "cluster" {
  count = var.create_cluster_role ? 1 : 0

  name = "${var.name}-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "${var.name}-cluster"
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policies" {
  for_each = var.create_cluster_role ? toset([
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSVPCResourceController",
  ]) : toset([])

  role       = aws_iam_role.cluster[0].name
  policy_arn = each.value
}

# ------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "cluster" {
  count = length(var.enabled_cluster_log_types) > 0 ? 1 : 0

  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = var.cluster_log_retention_days

  tags = merge(local.tags, {
    Name = "${var.name}-cluster-logs"
  })
}

# ------------------------------------------------------------------------------
# EKS CLUSTER
# ------------------------------------------------------------------------------

resource "aws_eks_cluster" "main" {
  name     = var.name
  role_arn = local.cluster_role_arn
  version  = var.kubernetes_version

  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = var.security_group_ids
  }

  dynamic "kubernetes_network_config" {
    for_each = var.service_ipv4_cidr != null || var.ip_family != "ipv4" ? [1] : []
    content {
      service_ipv4_cidr = var.service_ipv4_cidr
      ip_family         = var.ip_family
    }
  }

  dynamic "encryption_config" {
    for_each = var.encryption_config != null ? [var.encryption_config] : []
    content {
      provider {
        key_arn = encryption_config.value.provider_key_arn
      }
      resources = encryption_config.value.resources
    }
  }

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  }

  tags = merge(local.tags, {
    Name = var.name
  })

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policies,
    aws_cloudwatch_log_group.cluster,
  ]
}

# ------------------------------------------------------------------------------
# EKS CLUSTER ADD-ONS
# ------------------------------------------------------------------------------

resource "aws_eks_addon" "main" {
  for_each = local.cluster_addons

  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = each.key
  addon_version               = each.value.addon_version
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update
  service_account_role_arn    = each.value.service_account_role_arn
  configuration_values        = each.value.configuration_values

  tags = local.tags
}

# ------------------------------------------------------------------------------
# ACCESS ENTRIES
# ------------------------------------------------------------------------------

resource "aws_eks_access_entry" "main" {
  for_each = var.access_entries

  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = each.value.principal_arn
  kubernetes_groups = each.value.kubernetes_groups
  type              = each.value.type

  tags = local.tags
}

resource "aws_eks_access_policy_association" "main" {
  for_each = merge([
    for entry_key, entry in var.access_entries : {
      for policy_key, policy in entry.policy_associations :
      "${entry_key}-${policy_key}" => {
        principal_arn = entry.principal_arn
        policy_arn    = policy.policy_arn
        access_scope  = policy.access_scope
      }
    }
  ]...)

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.access_scope.type
    namespaces = each.value.access_scope.namespaces
  }

  depends_on = [aws_eks_access_entry.main]
}

# ------------------------------------------------------------------------------
# OIDC PROVIDER FOR IRSA
# ------------------------------------------------------------------------------

data "tls_certificate" "cluster" {
  count = var.enable_irsa ? 1 : 0

  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  count = var.enable_irsa ? 1 : 0

  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster[0].certificates[0].sha1_fingerprint]

  tags = merge(local.tags, {
    Name = var.name
  })
}
