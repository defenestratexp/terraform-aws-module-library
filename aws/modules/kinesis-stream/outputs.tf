# ------------------------------------------------------------------------------
# KINESIS STREAM OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The unique stream ID"
  value       = aws_kinesis_stream.main.id
}

output "arn" {
  description = "The ARN of the stream"
  value       = aws_kinesis_stream.main.arn
}

output "name" {
  description = "The name of the stream"
  value       = aws_kinesis_stream.main.name
}

output "shard_count" {
  description = "The number of shards"
  value       = aws_kinesis_stream.main.shard_count
}

output "stream_mode" {
  description = "The stream mode"
  value       = var.stream_mode
}

output "retention_period" {
  description = "The retention period in hours"
  value       = aws_kinesis_stream.main.retention_period
}

# ------------------------------------------------------------------------------
# CONSUMER OUTPUTS
# ------------------------------------------------------------------------------

output "consumer_arns" {
  description = "Map of consumer names to ARNs"
  value       = { for k, v in aws_kinesis_stream_consumer.main : k => v.arn }
}

output "consumer_ids" {
  description = "Map of consumer names to IDs"
  value       = { for k, v in aws_kinesis_stream_consumer.main : k => v.id }
}
