# ------------------------------------------------------------------------------
# KINESIS FIREHOSE MODULE
# Creates a Kinesis Firehose delivery stream
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "kinesis-firehose"
  }

  tags = merge(local.default_tags, var.tags)
}

# ------------------------------------------------------------------------------
# KINESIS FIREHOSE DELIVERY STREAM
# ------------------------------------------------------------------------------

resource "aws_kinesis_firehose_delivery_stream" "main" {
  name        = var.name
  destination = var.destination

  # Source configuration (Direct PUT or Kinesis Stream)
  dynamic "kinesis_source_configuration" {
    for_each = var.kinesis_source != null ? [var.kinesis_source] : []
    content {
      kinesis_stream_arn = kinesis_source_configuration.value.kinesis_stream_arn
      role_arn           = kinesis_source_configuration.value.role_arn
    }
  }

  # Server-side encryption
  dynamic "server_side_encryption" {
    for_each = var.server_side_encryption != null ? [var.server_side_encryption] : []
    content {
      enabled  = server_side_encryption.value.enabled
      key_type = server_side_encryption.value.key_type
      key_arn  = server_side_encryption.value.key_arn
    }
  }

  # S3 destination
  dynamic "extended_s3_configuration" {
    for_each = var.destination == "extended_s3" && var.s3_configuration != null ? [var.s3_configuration] : []
    content {
      bucket_arn          = extended_s3_configuration.value.bucket_arn
      role_arn            = extended_s3_configuration.value.role_arn
      prefix              = extended_s3_configuration.value.prefix
      error_output_prefix = extended_s3_configuration.value.error_output_prefix
      buffering_size      = extended_s3_configuration.value.buffering_size
      buffering_interval  = extended_s3_configuration.value.buffering_interval
      compression_format  = extended_s3_configuration.value.compression_format
      kms_key_arn         = extended_s3_configuration.value.kms_key_arn

      dynamic "cloudwatch_logging_options" {
        for_each = extended_s3_configuration.value.cloudwatch_logging != null ? [extended_s3_configuration.value.cloudwatch_logging] : []
        content {
          enabled         = cloudwatch_logging_options.value.enabled
          log_group_name  = cloudwatch_logging_options.value.log_group_name
          log_stream_name = cloudwatch_logging_options.value.log_stream_name
        }
      }

      dynamic "processing_configuration" {
        for_each = var.processing_configuration != null ? [var.processing_configuration] : []
        content {
          enabled = processing_configuration.value.enabled

          dynamic "processors" {
            for_each = processing_configuration.value.processors
            content {
              type = processors.value.type

              dynamic "parameters" {
                for_each = processors.value.parameters
                content {
                  parameter_name  = parameters.value.parameter_name
                  parameter_value = parameters.value.parameter_value
                }
              }
            }
          }
        }
      }

      dynamic "data_format_conversion_configuration" {
        for_each = var.data_format_conversion != null ? [var.data_format_conversion] : []
        content {
          enabled = data_format_conversion_configuration.value.enabled

          input_format_configuration {
            deserializer {
              dynamic "hive_json_ser_de" {
                for_each = data_format_conversion_configuration.value.input_format_configuration.deserializer.type == "HIVE_JSON" ? [1] : []
                content {
                  timestamp_formats = []
                }
              }
              dynamic "open_x_json_ser_de" {
                for_each = data_format_conversion_configuration.value.input_format_configuration.deserializer.type == "OPENX_JSON" ? [1] : []
                content {
                  case_insensitive                         = try(data_format_conversion_configuration.value.input_format_configuration.deserializer.parameters.case_insensitive, null)
                  column_to_json_key_mappings              = try(data_format_conversion_configuration.value.input_format_configuration.deserializer.parameters.column_to_json_key_mappings, null)
                  convert_dots_in_json_keys_to_underscores = try(data_format_conversion_configuration.value.input_format_configuration.deserializer.parameters.convert_dots_in_json_keys_to_underscores, null)
                }
              }
            }
          }

          output_format_configuration {
            serializer {
              dynamic "parquet_ser_de" {
                for_each = data_format_conversion_configuration.value.output_format_configuration.serializer.type == "PARQUET" ? [1] : []
                content {
                  block_size_bytes              = try(data_format_conversion_configuration.value.output_format_configuration.serializer.parameters.block_size_bytes, null)
                  compression                   = try(data_format_conversion_configuration.value.output_format_configuration.serializer.parameters.compression, null)
                  enable_dictionary_compression = try(data_format_conversion_configuration.value.output_format_configuration.serializer.parameters.enable_dictionary_compression, null)
                  max_padding_bytes             = try(data_format_conversion_configuration.value.output_format_configuration.serializer.parameters.max_padding_bytes, null)
                  page_size_bytes               = try(data_format_conversion_configuration.value.output_format_configuration.serializer.parameters.page_size_bytes, null)
                  writer_version                = try(data_format_conversion_configuration.value.output_format_configuration.serializer.parameters.writer_version, null)
                }
              }
              dynamic "orc_ser_de" {
                for_each = data_format_conversion_configuration.value.output_format_configuration.serializer.type == "ORC" ? [1] : []
                content {
                  bloom_filter_columns                    = try(data_format_conversion_configuration.value.output_format_configuration.serializer.parameters.bloom_filter_columns, null)
                  bloom_filter_false_positive_probability = try(data_format_conversion_configuration.value.output_format_configuration.serializer.parameters.bloom_filter_false_positive_probability, null)
                  dictionary_key_threshold                = try(data_format_conversion_configuration.value.output_format_configuration.serializer.parameters.dictionary_key_threshold, null)
                  format_version                          = try(data_format_conversion_configuration.value.output_format_configuration.serializer.parameters.format_version, null)
                  padding_tolerance                       = try(data_format_conversion_configuration.value.output_format_configuration.serializer.parameters.padding_tolerance, null)
                  row_index_stride                        = try(data_format_conversion_configuration.value.output_format_configuration.serializer.parameters.row_index_stride, null)
                  stripe_size_bytes                       = try(data_format_conversion_configuration.value.output_format_configuration.serializer.parameters.stripe_size_bytes, null)
                }
              }
            }
          }

          schema_configuration {
            database_name = data_format_conversion_configuration.value.schema_configuration.database_name
            table_name    = data_format_conversion_configuration.value.schema_configuration.table_name
            role_arn      = data_format_conversion_configuration.value.schema_configuration.role_arn
            region        = data_format_conversion_configuration.value.schema_configuration.region
            catalog_id    = data_format_conversion_configuration.value.schema_configuration.catalog_id
            version_id    = data_format_conversion_configuration.value.schema_configuration.version_id
          }
        }
      }
    }
  }

  # Redshift destination
  dynamic "redshift_configuration" {
    for_each = var.destination == "redshift" && var.redshift_configuration != null ? [var.redshift_configuration] : []
    content {
      cluster_jdbcurl    = redshift_configuration.value.cluster_jdbcurl
      username           = redshift_configuration.value.username
      password           = redshift_configuration.value.password
      role_arn           = redshift_configuration.value.role_arn
      data_table_name    = redshift_configuration.value.data_table_name
      copy_options       = redshift_configuration.value.copy_options
      data_table_columns = redshift_configuration.value.data_table_columns
      retry_duration     = redshift_configuration.value.retry_duration

      s3_configuration {
        bucket_arn         = redshift_configuration.value.s3_backup.bucket_arn
        role_arn           = redshift_configuration.value.role_arn
        prefix             = redshift_configuration.value.s3_backup.prefix
        buffering_size     = redshift_configuration.value.s3_backup.buffering_size
        buffering_interval = redshift_configuration.value.s3_backup.buffering_interval
        compression_format = redshift_configuration.value.s3_backup.compression_format
      }

      dynamic "cloudwatch_logging_options" {
        for_each = redshift_configuration.value.cloudwatch_logging != null ? [redshift_configuration.value.cloudwatch_logging] : []
        content {
          enabled         = cloudwatch_logging_options.value.enabled
          log_group_name  = cloudwatch_logging_options.value.log_group_name
          log_stream_name = cloudwatch_logging_options.value.log_stream_name
        }
      }

      dynamic "processing_configuration" {
        for_each = var.processing_configuration != null ? [var.processing_configuration] : []
        content {
          enabled = processing_configuration.value.enabled

          dynamic "processors" {
            for_each = processing_configuration.value.processors
            content {
              type = processors.value.type

              dynamic "parameters" {
                for_each = processors.value.parameters
                content {
                  parameter_name  = parameters.value.parameter_name
                  parameter_value = parameters.value.parameter_value
                }
              }
            }
          }
        }
      }
    }
  }

  # OpenSearch destination
  dynamic "opensearch_configuration" {
    for_each = var.destination == "opensearch" && var.opensearch_configuration != null ? [var.opensearch_configuration] : []
    content {
      domain_arn            = opensearch_configuration.value.domain_arn
      role_arn              = opensearch_configuration.value.role_arn
      index_name            = opensearch_configuration.value.index_name
      type_name             = opensearch_configuration.value.type_name
      index_rotation_period = opensearch_configuration.value.index_rotation_period
      buffering_size        = opensearch_configuration.value.buffering_size
      buffering_interval    = opensearch_configuration.value.buffering_interval
      retry_duration        = opensearch_configuration.value.retry_duration
      s3_backup_mode        = opensearch_configuration.value.s3_backup_mode

      s3_configuration {
        bucket_arn         = opensearch_configuration.value.s3_backup.bucket_arn
        role_arn           = opensearch_configuration.value.s3_backup.role_arn
        prefix             = opensearch_configuration.value.s3_backup.prefix
        buffering_size     = opensearch_configuration.value.s3_backup.buffering_size
        buffering_interval = opensearch_configuration.value.s3_backup.buffering_interval
        compression_format = opensearch_configuration.value.s3_backup.compression_format
      }

      dynamic "vpc_config" {
        for_each = opensearch_configuration.value.vpc_config != null ? [opensearch_configuration.value.vpc_config] : []
        content {
          subnet_ids         = vpc_config.value.subnet_ids
          security_group_ids = vpc_config.value.security_group_ids
          role_arn           = vpc_config.value.role_arn
        }
      }

      dynamic "cloudwatch_logging_options" {
        for_each = opensearch_configuration.value.cloudwatch_logging != null ? [opensearch_configuration.value.cloudwatch_logging] : []
        content {
          enabled         = cloudwatch_logging_options.value.enabled
          log_group_name  = cloudwatch_logging_options.value.log_group_name
          log_stream_name = cloudwatch_logging_options.value.log_stream_name
        }
      }

      dynamic "processing_configuration" {
        for_each = var.processing_configuration != null ? [var.processing_configuration] : []
        content {
          enabled = processing_configuration.value.enabled

          dynamic "processors" {
            for_each = processing_configuration.value.processors
            content {
              type = processors.value.type

              dynamic "parameters" {
                for_each = processors.value.parameters
                content {
                  parameter_name  = parameters.value.parameter_name
                  parameter_value = parameters.value.parameter_value
                }
              }
            }
          }
        }
      }
    }
  }

  # HTTP endpoint destination
  dynamic "http_endpoint_configuration" {
    for_each = var.destination == "http_endpoint" && var.http_endpoint_configuration != null ? [var.http_endpoint_configuration] : []
    content {
      url                = http_endpoint_configuration.value.url
      name               = http_endpoint_configuration.value.name
      access_key         = http_endpoint_configuration.value.access_key
      role_arn           = http_endpoint_configuration.value.role_arn
      buffering_size     = http_endpoint_configuration.value.buffering_size
      buffering_interval = http_endpoint_configuration.value.buffering_interval
      retry_duration     = http_endpoint_configuration.value.retry_duration
      s3_backup_mode     = http_endpoint_configuration.value.s3_backup_mode

      s3_configuration {
        bucket_arn         = http_endpoint_configuration.value.s3_backup.bucket_arn
        role_arn           = http_endpoint_configuration.value.role_arn
        prefix             = http_endpoint_configuration.value.s3_backup.prefix
        buffering_size     = http_endpoint_configuration.value.s3_backup.buffering_size
        buffering_interval = http_endpoint_configuration.value.s3_backup.buffering_interval
        compression_format = http_endpoint_configuration.value.s3_backup.compression_format
      }

      dynamic "request_configuration" {
        for_each = http_endpoint_configuration.value.request_configuration != null ? [http_endpoint_configuration.value.request_configuration] : []
        content {
          content_encoding = request_configuration.value.content_encoding

          dynamic "common_attributes" {
            for_each = request_configuration.value.common_attributes
            content {
              name  = common_attributes.value.name
              value = common_attributes.value.value
            }
          }
        }
      }

      dynamic "cloudwatch_logging_options" {
        for_each = http_endpoint_configuration.value.cloudwatch_logging != null ? [http_endpoint_configuration.value.cloudwatch_logging] : []
        content {
          enabled         = cloudwatch_logging_options.value.enabled
          log_group_name  = cloudwatch_logging_options.value.log_group_name
          log_stream_name = cloudwatch_logging_options.value.log_stream_name
        }
      }

      dynamic "processing_configuration" {
        for_each = var.processing_configuration != null ? [var.processing_configuration] : []
        content {
          enabled = processing_configuration.value.enabled

          dynamic "processors" {
            for_each = processing_configuration.value.processors
            content {
              type = processors.value.type

              dynamic "parameters" {
                for_each = processors.value.parameters
                content {
                  parameter_name  = parameters.value.parameter_name
                  parameter_value = parameters.value.parameter_value
                }
              }
            }
          }
        }
      }
    }
  }

  tags = merge(local.tags, {
    Name = var.name
  })
}
