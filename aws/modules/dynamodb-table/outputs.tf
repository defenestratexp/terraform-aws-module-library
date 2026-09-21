# ------------------------------------------------------------------------------
# DYNAMODB TABLE OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The name of the table"
  value       = aws_dynamodb_table.main.id
}

output "arn" {
  description = "The ARN of the table"
  value       = aws_dynamodb_table.main.arn
}

output "name" {
  description = "The name of the table"
  value       = aws_dynamodb_table.main.name
}

output "hash_key" {
  description = "The hash key of the table"
  value       = aws_dynamodb_table.main.hash_key
}

output "range_key" {
  description = "The range key of the table"
  value       = aws_dynamodb_table.main.range_key
}

output "stream_arn" {
  description = "The ARN of the DynamoDB stream"
  value       = aws_dynamodb_table.main.stream_arn
}

output "stream_label" {
  description = "The timestamp of the DynamoDB stream"
  value       = aws_dynamodb_table.main.stream_label
}

output "global_secondary_index_names" {
  description = "List of global secondary index names"
  value       = [for gsi in var.global_secondary_indexes : gsi.name]
}

output "local_secondary_index_names" {
  description = "List of local secondary index names"
  value       = [for lsi in var.local_secondary_indexes : lsi.name]
}

output "replica_arns" {
  description = "Map of replica region to ARN"
  value = {
    for replica in aws_dynamodb_table.main.replica : replica.region_name => replica.arn
  }
}
