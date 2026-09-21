# ------------------------------------------------------------------------------
# EFS OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the EFS file system"
  value       = aws_efs_file_system.main.id
}

output "arn" {
  description = "The ARN of the EFS file system"
  value       = aws_efs_file_system.main.arn
}

output "dns_name" {
  description = "The DNS name for the EFS file system"
  value       = aws_efs_file_system.main.dns_name
}

output "mount_target_ids" {
  description = "Map of subnet ID to mount target ID"
  value       = { for k, v in aws_efs_mount_target.main : k => v.id }
}

output "mount_target_dns_names" {
  description = "Map of subnet ID to mount target DNS name"
  value       = { for k, v in aws_efs_mount_target.main : k => v.dns_name }
}

output "mount_target_network_interface_ids" {
  description = "Map of subnet ID to mount target network interface ID"
  value       = { for k, v in aws_efs_mount_target.main : k => v.network_interface_id }
}

output "access_point_ids" {
  description = "Map of access point name to access point ID"
  value       = { for k, v in aws_efs_access_point.main : k => v.id }
}

output "access_point_arns" {
  description = "Map of access point name to access point ARN"
  value       = { for k, v in aws_efs_access_point.main : k => v.arn }
}

output "size_in_bytes" {
  description = "The current size of the file system in bytes"
  value       = aws_efs_file_system.main.size_in_bytes
}
