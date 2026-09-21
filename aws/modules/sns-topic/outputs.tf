# ------------------------------------------------------------------------------
# SNS TOPIC OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The ARN of the SNS topic"
  value       = aws_sns_topic.main.id
}

output "arn" {
  description = "The ARN of the SNS topic"
  value       = aws_sns_topic.main.arn
}

output "name" {
  description = "The name of the SNS topic"
  value       = aws_sns_topic.main.name
}

output "owner" {
  description = "The AWS account ID of the topic owner"
  value       = aws_sns_topic.main.owner
}
