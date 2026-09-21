# ------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER OUTPUTS
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

# Listener outputs
output "http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = var.create_http_listener ? aws_lb_listener.http[0].arn : null
}

output "https_listener_arn" {
  description = "The ARN of the HTTPS listener"
  value       = var.create_https_listener ? aws_lb_listener.https[0].arn : null
}

# Convenience outputs
output "url" {
  description = "The URL of the load balancer"
  value       = var.internal ? "http://${aws_lb.main.dns_name}" : "https://${aws_lb.main.dns_name}"
}
