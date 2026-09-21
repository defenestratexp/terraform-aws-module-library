# ------------------------------------------------------------------------------
# SQS QUEUE OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The URL of the SQS queue"
  value       = aws_sqs_queue.main.id
}

output "arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.main.arn
}

output "name" {
  description = "The name of the SQS queue"
  value       = aws_sqs_queue.main.name
}

output "url" {
  description = "The URL of the SQS queue"
  value       = aws_sqs_queue.main.url
}

# ------------------------------------------------------------------------------
# DEAD LETTER QUEUE OUTPUTS
# ------------------------------------------------------------------------------

output "dlq_id" {
  description = "The URL of the dead letter queue"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].id : null
}

output "dlq_arn" {
  description = "The ARN of the dead letter queue"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].arn : null
}

output "dlq_name" {
  description = "The name of the dead letter queue"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].name : null
}

output "dlq_url" {
  description = "The URL of the dead letter queue"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].url : null
}
