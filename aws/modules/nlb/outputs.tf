# ------------------------------------------------------------------------------
# NETWORK LOAD BALANCER OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the load balancer"
  value       = aws_lb.main.id
}

output "arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "arn_suffix" {
  description = "The ARN suffix of the load balancer (for CloudWatch metrics)"
  value       = aws_lb.main.arn_suffix
}

output "name" {
  description = "The name of the load balancer"
  value       = aws_lb.main.name
}

output "dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "zone_id" {
  description = "The zone ID of the load balancer (for Route53 alias records)"
  value       = aws_lb.main.zone_id
}

output "listener_arns" {
  description = "The ARNs of the listeners"
  value       = aws_lb_listener.main[*].arn
}
