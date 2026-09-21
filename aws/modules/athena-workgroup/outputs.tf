# ------------------------------------------------------------------------------
# ATHENA WORKGROUP OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The workgroup name"
  value       = aws_athena_workgroup.main.id
}

output "arn" {
  description = "The ARN of the workgroup"
  value       = aws_athena_workgroup.main.arn
}

output "name" {
  description = "The name of the workgroup"
  value       = aws_athena_workgroup.main.name
}

output "state" {
  description = "The state of the workgroup"
  value       = aws_athena_workgroup.main.state
}

# ------------------------------------------------------------------------------
# NAMED QUERY OUTPUTS
# ------------------------------------------------------------------------------

output "named_query_ids" {
  description = "Map of named query names to IDs"
  value       = { for k, v in aws_athena_named_query.main : k => v.id }
}
