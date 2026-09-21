# ------------------------------------------------------------------------------
# ATHENA WORKGROUP MODULE
# Creates an Athena workgroup with query configuration
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "athena-workgroup"
  }

  tags = merge(local.default_tags, var.tags)
}

# ------------------------------------------------------------------------------
# ATHENA WORKGROUP
# ------------------------------------------------------------------------------

resource "aws_athena_workgroup" "main" {
  name          = var.name
  description   = var.description
  state         = var.state
  force_destroy = var.force_destroy

  configuration {
    enforce_workgroup_configuration    = var.enforce_workgroup_configuration
    publish_cloudwatch_metrics_enabled = var.publish_cloudwatch_metrics_enabled
    bytes_scanned_cutoff_per_query     = var.bytes_scanned_cutoff_per_query
    requester_pays_enabled             = var.requester_pays_enabled
    execution_role                     = var.execution_role

    dynamic "result_configuration" {
      for_each = var.output_location != null ? [1] : []
      content {
        output_location       = var.output_location
        expected_bucket_owner = var.expected_bucket_owner

        dynamic "encryption_configuration" {
          for_each = var.encryption_configuration != null ? [var.encryption_configuration] : []
          content {
            encryption_option = encryption_configuration.value.encryption_option
            kms_key_arn       = encryption_configuration.value.kms_key_arn
          }
        }

        dynamic "acl_configuration" {
          for_each = var.acl_configuration != null ? [var.acl_configuration] : []
          content {
            s3_acl_option = acl_configuration.value.s3_acl_option
          }
        }
      }
    }

    dynamic "engine_version" {
      for_each = var.engine_version != null ? [var.engine_version] : []
      content {
        selected_engine_version = engine_version.value.selected_engine_version
      }
    }
  }

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# NAMED QUERIES
# ------------------------------------------------------------------------------

resource "aws_athena_named_query" "main" {
  for_each = var.named_queries

  name        = each.key
  description = each.value.description
  workgroup   = aws_athena_workgroup.main.name
  database    = each.value.database
  query       = each.value.query
}
