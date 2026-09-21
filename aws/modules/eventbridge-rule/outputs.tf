# ------------------------------------------------------------------------------
# EVENTBRIDGE RULE OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ID of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.main.id
}

output "arn" {
  description = "The ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.main.arn
}

output "name" {
  description = "The name of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.main.name
}

output "event_bus_name" {
  description = "The event bus name"
  value       = aws_cloudwatch_event_rule.main.event_bus_name
}

# ------------------------------------------------------------------------------
# TARGET OUTPUTS
# ------------------------------------------------------------------------------

output "target_ids" {
  description = "Map of target names to their IDs"
  value       = { for k, v in aws_cloudwatch_event_target.main : k => v.target_id }
}

output "target_arns" {
  description = "Map of target names to their ARNs"
  value       = { for k, v in aws_cloudwatch_event_target.main : k => v.arn }
}
