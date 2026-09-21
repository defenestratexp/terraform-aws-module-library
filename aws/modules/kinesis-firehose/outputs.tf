# ------------------------------------------------------------------------------
# KINESIS FIREHOSE OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The delivery stream ID"
  value       = aws_kinesis_firehose_delivery_stream.main.id
}

output "arn" {
  description = "The ARN of the delivery stream"
  value       = aws_kinesis_firehose_delivery_stream.main.arn
}

output "name" {
  description = "The name of the delivery stream"
  value       = aws_kinesis_firehose_delivery_stream.main.name
}

output "destination" {
  description = "The destination type"
  value       = aws_kinesis_firehose_delivery_stream.main.destination
}
