# ------------------------------------------------------------------------------
# EBS VOLUME OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the EBS volume"
  value       = aws_ebs_volume.main.id
}

output "arn" {
  description = "The ARN of the EBS volume"
  value       = aws_ebs_volume.main.arn
}

output "availability_zone" {
  description = "The availability zone of the volume"
  value       = aws_ebs_volume.main.availability_zone
}

output "size" {
  description = "The size of the volume in GiB"
  value       = aws_ebs_volume.main.size
}

output "type" {
  description = "The type of the volume"
  value       = aws_ebs_volume.main.type
}

output "iops" {
  description = "The IOPS of the volume"
  value       = aws_ebs_volume.main.iops
}

output "throughput" {
  description = "The throughput of the volume in MiB/s"
  value       = aws_ebs_volume.main.throughput
}

output "encrypted" {
  description = "Whether the volume is encrypted"
  value       = aws_ebs_volume.main.encrypted
}

output "attachment_instance_id" {
  description = "The instance ID the volume is attached to (if attached)"
  value       = var.attach_to_instance != "" ? aws_volume_attachment.main[0].instance_id : null
}

output "attachment_device_name" {
  description = "The device name (if attached)"
  value       = var.attach_to_instance != "" ? aws_volume_attachment.main[0].device_name : null
}
