# ------------------------------------------------------------------------------
# GLUE CATALOG DATABASE MODULE
# Creates a Glue Data Catalog database with optional tables
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  catalog_id = var.catalog_id != null ? var.catalog_id : data.aws_caller_identity.current.account_id
}

# ------------------------------------------------------------------------------
# GLUE CATALOG DATABASE
# ------------------------------------------------------------------------------

resource "aws_glue_catalog_database" "main" {
  name         = var.name
  description  = var.description
  catalog_id   = local.catalog_id
  location_uri = var.location_uri
  parameters   = var.parameters

  dynamic "target_database" {
    for_each = var.target_database != null ? [var.target_database] : []
    content {
      catalog_id    = target_database.value.catalog_id
      database_name = target_database.value.database_name
      region        = target_database.value.region
    }
  }

  dynamic "create_table_default_permission" {
    for_each = var.create_table_default_permissions != null ? var.create_table_default_permissions : []
    content {
      permissions = create_table_default_permission.value.permissions

      principal {
        data_lake_principal_identifier = create_table_default_permission.value.principal.data_lake_principal_identifier
      }
    }
  }
}

# ------------------------------------------------------------------------------
# GLUE CATALOG TABLES
# ------------------------------------------------------------------------------

resource "aws_glue_catalog_table" "main" {
  for_each = var.tables

  database_name = aws_glue_catalog_database.main.name
  catalog_id    = local.catalog_id
  name          = each.key
  description   = each.value.description
  table_type    = each.value.table_type
  parameters    = each.value.parameters
  owner         = each.value.owner
  retention     = each.value.retention

  dynamic "storage_descriptor" {
    for_each = each.value.storage_descriptor != null ? [each.value.storage_descriptor] : []
    content {
      location                  = storage_descriptor.value.location
      input_format              = storage_descriptor.value.input_format
      output_format             = storage_descriptor.value.output_format
      compressed                = storage_descriptor.value.compressed
      number_of_buckets         = storage_descriptor.value.number_of_buckets
      bucket_columns            = storage_descriptor.value.bucket_columns
      stored_as_sub_directories = storage_descriptor.value.stored_as_sub_directories

      dynamic "ser_de_info" {
        for_each = storage_descriptor.value.ser_de_info != null ? [storage_descriptor.value.ser_de_info] : []
        content {
          name                  = ser_de_info.value.name
          serialization_library = ser_de_info.value.serialization_library
          parameters            = ser_de_info.value.parameters
        }
      }

      dynamic "columns" {
        for_each = storage_descriptor.value.columns
        content {
          name       = columns.value.name
          type       = columns.value.type
          comment    = columns.value.comment
          parameters = columns.value.parameters
        }
      }

      dynamic "sort_columns" {
        for_each = storage_descriptor.value.sort_columns
        content {
          column     = sort_columns.value.column
          sort_order = sort_columns.value.sort_order
        }
      }

      dynamic "skewed_info" {
        for_each = storage_descriptor.value.skewed_info != null ? [storage_descriptor.value.skewed_info] : []
        content {
          skewed_column_names               = skewed_info.value.skewed_column_names
          skewed_column_value_location_maps = skewed_info.value.skewed_column_value_location_maps
          skewed_column_values              = skewed_info.value.skewed_column_values
        }
      }
    }
  }

  dynamic "partition_keys" {
    for_each = each.value.partition_keys
    content {
      name    = partition_keys.value.name
      type    = partition_keys.value.type
      comment = partition_keys.value.comment
    }
  }
}
