# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the Glue catalog database"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DATABASE SETTINGS
# ------------------------------------------------------------------------------

variable "description" {
  description = "Description of the database"
  type        = string
  default     = null
}

variable "location_uri" {
  description = "Location of the database (S3 path)"
  type        = string
  default     = null
}

variable "parameters" {
  description = "Map of parameters for the database"
  type        = map(string)
  default     = {}
}

variable "catalog_id" {
  description = "ID of the Glue Catalog (defaults to current account)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TARGET DATABASE
# ------------------------------------------------------------------------------

variable "target_database" {
  description = "Target database for resource linking"
  type = object({
    catalog_id    = string
    database_name = string
    region        = optional(string)
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - PERMISSIONS
# ------------------------------------------------------------------------------

variable "create_table_default_permissions" {
  description = "Default permissions for tables created in the database"
  type = list(object({
    permissions = list(string)
    principal = object({
      data_lake_principal_identifier = string
    })
  }))
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TABLES
# ------------------------------------------------------------------------------

variable "tables" {
  description = "Map of tables to create in this database"
  type = map(object({
    description = optional(string)
    table_type  = optional(string, "EXTERNAL_TABLE")
    parameters  = optional(map(string), {})
    owner       = optional(string)
    retention   = optional(number, 0)
    storage_descriptor = optional(object({
      location                  = optional(string)
      input_format              = optional(string)
      output_format             = optional(string)
      compressed                = optional(bool, false)
      number_of_buckets         = optional(number, 0)
      bucket_columns            = optional(list(string))
      stored_as_sub_directories = optional(bool, false)
      ser_de_info = optional(object({
        name                  = optional(string)
        serialization_library = optional(string)
        parameters            = optional(map(string), {})
      }))
      columns = optional(list(object({
        name       = string
        type       = string
        comment    = optional(string)
        parameters = optional(map(string))
      })), [])
      sort_columns = optional(list(object({
        column     = string
        sort_order = number
      })), [])
      skewed_info = optional(object({
        skewed_column_names               = optional(list(string))
        skewed_column_value_location_maps = optional(map(string))
        skewed_column_values              = optional(list(string))
      }))
    }))
    partition_keys = optional(list(object({
      name    = string
      type    = string
      comment = optional(string)
    })), [])
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags (applied to tables)"
  type        = map(string)
  default     = {}
}
