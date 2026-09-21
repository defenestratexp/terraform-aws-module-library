# ------------------------------------------------------------------------------
# EKS NODE GROUP OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The EKS node group ID"
  value       = aws_eks_node_group.main.id
}

output "arn" {
  description = "The ARN of the EKS node group"
  value       = aws_eks_node_group.main.arn
}

output "status" {
  description = "The status of the EKS node group"
  value       = aws_eks_node_group.main.status
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_node_group.main.cluster_name
}

output "node_group_name" {
  description = "The name of the node group"
  value       = aws_eks_node_group.main.node_group_name
}

# ------------------------------------------------------------------------------
# SCALING OUTPUTS
# ------------------------------------------------------------------------------

output "scaling_config" {
  description = "The scaling configuration"
  value = {
    desired_size = aws_eks_node_group.main.scaling_config[0].desired_size
    min_size     = aws_eks_node_group.main.scaling_config[0].min_size
    max_size     = aws_eks_node_group.main.scaling_config[0].max_size
  }
}

# ------------------------------------------------------------------------------
# RESOURCE OUTPUTS
# ------------------------------------------------------------------------------

output "resources" {
  description = "Resources created by the node group"
  value = {
    autoscaling_groups              = aws_eks_node_group.main.resources[0].autoscaling_groups
    remote_access_security_group_id = try(aws_eks_node_group.main.resources[0].remote_access_security_group_id, null)
  }
}

output "autoscaling_group_names" {
  description = "Names of the Auto Scaling Groups"
  value       = [for asg in aws_eks_node_group.main.resources[0].autoscaling_groups : asg.name]
}

# ------------------------------------------------------------------------------
# IAM OUTPUTS
# ------------------------------------------------------------------------------

output "node_role_arn" {
  description = "The ARN of the node IAM role"
  value       = local.node_role_arn
}

output "node_role_name" {
  description = "The name of the node IAM role"
  value       = var.create_node_role ? aws_iam_role.node[0].name : null
}
