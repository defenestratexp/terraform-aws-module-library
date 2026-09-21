# ------------------------------------------------------------------------------
# EKS CLUSTER OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "arn" {
  description = "The ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

output "name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "endpoint" {
  description = "The endpoint for the Kubernetes API server"
  value       = aws_eks_cluster.main.endpoint
}

output "certificate_authority_data" {
  description = "Base64 encoded certificate data for cluster authentication"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "version" {
  description = "The Kubernetes version of the cluster"
  value       = aws_eks_cluster.main.version
}

output "platform_version" {
  description = "The platform version of the cluster"
  value       = aws_eks_cluster.main.platform_version
}

output "status" {
  description = "The status of the EKS cluster"
  value       = aws_eks_cluster.main.status
}

# ------------------------------------------------------------------------------
# NETWORK OUTPUTS
# ------------------------------------------------------------------------------

output "vpc_config" {
  description = "The VPC configuration of the cluster"
  value = {
    cluster_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
    vpc_id                    = aws_eks_cluster.main.vpc_config[0].vpc_id
    subnet_ids                = aws_eks_cluster.main.vpc_config[0].subnet_ids
  }
}

output "cluster_security_group_id" {
  description = "The security group ID created by EKS for the cluster"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

# ------------------------------------------------------------------------------
# IAM OUTPUTS
# ------------------------------------------------------------------------------

output "cluster_role_arn" {
  description = "The ARN of the cluster IAM role"
  value       = local.cluster_role_arn
}

output "cluster_role_name" {
  description = "The name of the cluster IAM role"
  value       = var.create_cluster_role ? aws_iam_role.cluster[0].name : null
}

# ------------------------------------------------------------------------------
# OIDC OUTPUTS
# ------------------------------------------------------------------------------

output "oidc_issuer" {
  description = "The OIDC issuer URL"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL without protocol"
  value       = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider"
  value       = var.enable_irsa ? aws_iam_openid_connect_provider.cluster[0].arn : null
}

# ------------------------------------------------------------------------------
# ADD-ON OUTPUTS
# ------------------------------------------------------------------------------

output "addon_versions" {
  description = "Map of installed add-on versions"
  value       = { for k, v in aws_eks_addon.main : k => v.addon_version }
}

# ------------------------------------------------------------------------------
# KUBECONFIG HELPER
# ------------------------------------------------------------------------------

output "kubeconfig_command" {
  description = "AWS CLI command to update kubeconfig"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${data.aws_caller_identity.current.account_id}"
}
