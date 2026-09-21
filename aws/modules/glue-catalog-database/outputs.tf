# ------------------------------------------------------------------------------
# GLUE CATALOG DATABASE OUTPUTS
# ------------------------------------------------------------------------------

output "id" {
  description = "The catalog ID and database name"
  value       = aws_glue_catalog_database.main.id
}

output "arn" {
  description = "The ARN of the Glue catalog database"
  value       = aws_glue_catalog_database.main.arn
}

output "name" {
  description = "The name of the database"
  value       = aws_glue_catalog_database.main.name
}

output "catalog_id" {
  description = "The catalog ID"
  value       = local.catalog_id
}

# ------------------------------------------------------------------------------
# TABLE OUTPUTS
# ------------------------------------------------------------------------------

output "table_arns" {
  description = "Map of table names to ARNs"
  value       = { for k, v in aws_glue_catalog_table.main : k => v.arn }
}

output "table_ids" {
  description = "Map of table names to IDs"
  value       = { for k, v in aws_glue_catalog_table.main : k => v.id }
}
