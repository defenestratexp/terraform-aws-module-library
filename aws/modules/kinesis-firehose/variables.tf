# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the Firehose delivery stream"
  type        = string
}

variable "destination" {
  description = "Destination type (extended_s3, redshift, opensearch, splunk, http_endpoint)"
  type        = string

  validation {
    condition     = contains(["extended_s3", "redshift", "opensearch", "splunk", "http_endpoint"], var.destination)
    error_message = "Destination must be extended_s3, redshift, opensearch, splunk, or http_endpoint."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SOURCE
# ------------------------------------------------------------------------------

variable "kinesis_source" {
  description = "Kinesis Data Stream as source"
  type = object({
    kinesis_stream_arn = string
    role_arn           = string
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - S3 DESTINATION
# ------------------------------------------------------------------------------

variable "s3_configuration" {
  description = "S3 destination configuration"
  type = object({
    bucket_arn          = string
    role_arn            = string
    prefix              = optional(string)
    error_output_prefix = optional(string)
    buffering_size      = optional(number, 5)
    buffering_interval  = optional(number, 300)
    compression_format  = optional(string, "GZIP")
    kms_key_arn         = optional(string)
    cloudwatch_logging = optional(object({
      enabled         = bool
      log_group_name  = optional(string)
      log_stream_name = optional(string)
    }))
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - REDSHIFT DESTINATION
# ------------------------------------------------------------------------------

variable "redshift_configuration" {
  description = "Redshift destination configuration"
  type = object({
    cluster_jdbcurl    = string
    username           = string
    password           = string
    role_arn           = string
    data_table_name    = string
    copy_options       = optional(string)
    data_table_columns = optional(string)
    retry_duration     = optional(number, 3600)
    s3_backup = object({
      bucket_arn         = string
      prefix             = optional(string)
      buffering_size     = optional(number, 5)
      buffering_interval = optional(number, 300)
      compression_format = optional(string, "GZIP")
    })
    cloudwatch_logging = optional(object({
      enabled         = bool
      log_group_name  = optional(string)
      log_stream_name = optional(string)
    }))
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - OPENSEARCH DESTINATION
# ------------------------------------------------------------------------------

variable "opensearch_configuration" {
  description = "OpenSearch destination configuration"
  type = object({
    domain_arn            = string
    role_arn              = string
    index_name            = string
    type_name             = optional(string)
    index_rotation_period = optional(string, "OneDay")
    buffering_size        = optional(number, 5)
    buffering_interval    = optional(number, 300)
    retry_duration        = optional(number, 300)
    s3_backup_mode        = optional(string, "FailedDocumentsOnly")
    s3_backup = object({
      bucket_arn         = string
      role_arn           = string
      prefix             = optional(string)
      buffering_size     = optional(number, 5)
      buffering_interval = optional(number, 300)
      compression_format = optional(string, "GZIP")
    })
    vpc_config = optional(object({
      subnet_ids         = list(string)
      security_group_ids = list(string)
      role_arn           = string
    }))
    cloudwatch_logging = optional(object({
      enabled         = bool
      log_group_name  = optional(string)
      log_stream_name = optional(string)
    }))
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - HTTP ENDPOINT DESTINATION
# ------------------------------------------------------------------------------

variable "http_endpoint_configuration" {
  description = "HTTP endpoint destination configuration"
  type = object({
    url                = string
    name               = optional(string)
    access_key         = optional(string)
    role_arn           = string
    buffering_size     = optional(number, 5)
    buffering_interval = optional(number, 300)
    retry_duration     = optional(number, 300)
    s3_backup_mode     = optional(string, "FailedDataOnly")
    s3_backup = object({
      bucket_arn         = string
      prefix             = optional(string)
      buffering_size     = optional(number, 5)
      buffering_interval = optional(number, 300)
      compression_format = optional(string, "GZIP")
    })
    request_configuration = optional(object({
      content_encoding = optional(string, "NONE")
      common_attributes = optional(list(object({
        name  = string
        value = string
      })), [])
    }))
    cloudwatch_logging = optional(object({
      enabled         = bool
      log_group_name  = optional(string)
      log_stream_name = optional(string)
    }))
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DATA TRANSFORMATION
# ------------------------------------------------------------------------------

variable "processing_configuration" {
  description = "Data processing/transformation configuration"
  type = object({
    enabled = bool
    processors = list(object({
      type = string
      parameters = list(object({
        parameter_name  = string
        parameter_value = string
      }))
    }))
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DATA FORMAT CONVERSION
# ------------------------------------------------------------------------------

variable "data_format_conversion" {
  description = "Data format conversion configuration (Parquet/ORC)"
  type = object({
    enabled = bool
    input_format_configuration = object({
      deserializer = object({
        type = string # "HIVE_JSON", "OPENX_JSON"
        parameters = optional(object({
          case_insensitive                         = optional(bool)
          column_to_json_key_mappings              = optional(map(string))
          convert_dots_in_json_keys_to_underscores = optional(bool)
        }))
      })
    })
    output_format_configuration = object({
      serializer = object({
        type = string # "PARQUET", "ORC"
        parameters = optional(object({
          # Parquet parameters
          block_size_bytes              = optional(number)
          compression                   = optional(string)
          enable_dictionary_compression = optional(bool)
          max_padding_bytes             = optional(number)
          page_size_bytes               = optional(number)
          writer_version                = optional(string)
          # ORC parameters
          bloom_filter_columns                    = optional(list(string))
          bloom_filter_false_positive_probability = optional(number)
          dictionary_key_threshold                = optional(number)
          format_version                          = optional(string)
          padding_tolerance                       = optional(number)
          row_index_stride                        = optional(number)
          stripe_size_bytes                       = optional(number)
        }))
      })
    })
    schema_configuration = object({
      database_name = string
      table_name    = string
      role_arn      = string
      region        = optional(string)
      catalog_id    = optional(string)
      version_id    = optional(string)
    })
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SERVER-SIDE ENCRYPTION
# ------------------------------------------------------------------------------

variable "server_side_encryption" {
  description = "Server-side encryption configuration"
  type = object({
    enabled  = bool
    key_type = optional(string, "AWS_OWNED_CMK")
    key_arn  = optional(string)
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
