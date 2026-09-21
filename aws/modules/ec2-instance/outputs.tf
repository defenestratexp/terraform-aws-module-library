# ------------------------------------------------------------------------------
# EC2 INSTANCE OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the instance"
  value       = aws_instance.main.id
}

output "arn" {
  description = "The ARN of the instance"
  value       = aws_instance.main.arn
}

output "instance_id" {
  description = "Alias for id - The ID of the instance"
  value       = aws_instance.main.id
}

output "private_ip" {
  description = "The private IP address of the instance"
  value       = aws_instance.main.private_ip
}

output "public_ip" {
  description = "The public IP address of the instance (if applicable)"
  value       = aws_instance.main.public_ip
}

output "private_dns" {
  description = "The private DNS name of the instance"
  value       = aws_instance.main.private_dns
}

output "public_dns" {
  description = "The public DNS name of the instance (if applicable)"
  value       = aws_instance.main.public_dns
}

output "availability_zone" {
  description = "The availability zone of the instance"
  value       = aws_instance.main.availability_zone
}

output "subnet_id" {
  description = "The subnet ID of the instance"
  value       = aws_instance.main.subnet_id
}

output "vpc_security_group_ids" {
  description = "The security group IDs attached to the instance"
  value       = aws_instance.main.vpc_security_group_ids
}

output "ami_id" {
  description = "The AMI ID used for the instance"
  value       = aws_instance.main.ami
}

output "instance_type" {
  description = "The instance type"
  value       = aws_instance.main.instance_type
}

output "instance_state" {
  description = "The state of the instance"
  value       = aws_instance.main.instance_state
}

output "root_volume_id" {
  description = "The ID of the root EBS volume"
  value       = aws_instance.main.root_block_device[0].volume_id
}

output "additional_volume_ids" {
  description = "List of additional EBS volume IDs"
  value       = aws_ebs_volume.additional[*].id
}
