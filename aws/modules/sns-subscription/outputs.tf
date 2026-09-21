# ------------------------------------------------------------------------------
# SNS SUBSCRIPTION OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ARN of the subscription"
  value       = aws_sns_topic_subscription.main.id
}

output "arn" {
  description = "The ARN of the subscription"
  value       = aws_sns_topic_subscription.main.arn
}

output "topic_arn" {
  description = "The ARN of the topic"
  value       = aws_sns_topic_subscription.main.topic_arn
}

output "protocol" {
  description = "The protocol of the subscription"
  value       = aws_sns_topic_subscription.main.protocol
}

output "endpoint" {
  description = "The endpoint of the subscription"
  value       = aws_sns_topic_subscription.main.endpoint
}

output "confirmation_was_authenticated" {
  description = "Whether the subscription confirmation was authenticated"
  value       = aws_sns_topic_subscription.main.confirmation_was_authenticated
}

output "owner_id" {
  description = "The AWS account ID of the subscription owner"
  value       = aws_sns_topic_subscription.main.owner_id
}

output "pending_confirmation" {
  description = "Whether the subscription is pending confirmation"
  value       = aws_sns_topic_subscription.main.pending_confirmation
}
