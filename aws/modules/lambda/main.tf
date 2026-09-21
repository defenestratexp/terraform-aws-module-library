# ------------------------------------------------------------------------------
# LAMBDA FUNCTION MODULE
# Creates a Lambda function with IAM role, logging, and optional triggers
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "lambda"
  }

  tags = merge(local.default_tags, var.tags)

  role_arn = var.role_arn != null ? var.role_arn : (var.create_role ? aws_iam_role.lambda[0].arn : null)

  # Determine source type
  use_source_path = var.source_path != null
  use_s3          = var.s3_bucket != null && var.s3_key != null
  use_image       = var.image_uri != null
}

# ------------------------------------------------------------------------------
# ARCHIVE SOURCE CODE (if source_path provided)
# ------------------------------------------------------------------------------

data "archive_file" "source" {
  count = local.use_source_path ? 1 : 0

  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.module}/.terraform/tmp/${var.function_name}.zip"
}

# ------------------------------------------------------------------------------
# IAM ROLE
# ------------------------------------------------------------------------------

resource "aws_iam_role" "lambda" {
  count = var.create_role ? 1 : 0

  name = "${var.function_name}-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "${var.function_name}-lambda"
  })
}

# Basic execution role policy (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  count = var.create_role ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC execution role policy
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count = var.create_role && var.vpc_config != null ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# X-Ray tracing policy
resource "aws_iam_role_policy_attachment" "lambda_xray" {
  count = var.create_role && var.tracing_mode != null ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# Additional policies
resource "aws_iam_role_policy_attachment" "additional" {
  for_each = var.create_role ? var.role_policies : {}

  role       = aws_iam_role.lambda[0].name
  policy_arn = each.value
}

# Inline policies
resource "aws_iam_role_policy" "inline" {
  for_each = var.create_role ? var.role_inline_policies : {}

  name   = each.key
  role   = aws_iam_role.lambda[0].name
  policy = each.value
}

# ------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.cloudwatch_log_retention_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = merge(local.tags, {
    Name = "${var.function_name}-logs"
  })
}

# ------------------------------------------------------------------------------
# LAMBDA FUNCTION
# ------------------------------------------------------------------------------

resource "aws_lambda_function" "main" {
  function_name = var.function_name
  description   = var.description
  role          = local.role_arn

  # Source code
  filename          = local.use_source_path ? data.archive_file.source[0].output_path : var.filename
  source_code_hash  = local.use_source_path ? data.archive_file.source[0].output_base64sha256 : null
  s3_bucket         = local.use_s3 ? var.s3_bucket : null
  s3_key            = local.use_s3 ? var.s3_key : null
  s3_object_version = local.use_s3 ? var.s3_object_version : null
  image_uri         = local.use_image ? var.image_uri : null
  package_type      = var.package_type

  # Runtime configuration
  handler       = var.package_type == "Zip" ? var.handler : null
  runtime       = var.package_type == "Zip" ? var.runtime : null
  architectures = var.architectures
  layers        = var.layers

  # Resource configuration
  memory_size                    = var.memory_size
  timeout                        = var.timeout
  reserved_concurrent_executions = var.reserved_concurrent_executions
  publish                        = var.publish

  # Environment variables
  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  # VPC configuration
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  # Tracing
  dynamic "tracing_config" {
    for_each = var.tracing_mode != null ? [var.tracing_mode] : []
    content {
      mode = tracing_config.value
    }
  }

  # Dead letter queue
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_config != null ? [var.dead_letter_config] : []
    content {
      target_arn = dead_letter_config.value.target_arn
    }
  }

  # File system
  dynamic "file_system_config" {
    for_each = var.file_system_config != null ? [var.file_system_config] : []
    content {
      arn              = file_system_config.value.arn
      local_mount_path = file_system_config.value.local_mount_path
    }
  }

  # Ephemeral storage
  ephemeral_storage {
    size = var.ephemeral_storage_size
  }

  # Logging configuration
  dynamic "logging_config" {
    for_each = var.logging_config != null ? [var.logging_config] : []
    content {
      log_format            = logging_config.value.log_format
      application_log_level = logging_config.value.application_log_level
      system_log_level      = logging_config.value.system_log_level
      log_group             = aws_cloudwatch_log_group.lambda.name
    }
  }

  tags = merge(local.tags, {
    Name = var.function_name
  })

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_vpc,
    aws_cloudwatch_log_group.lambda,
  ]
}

# ------------------------------------------------------------------------------
# FUNCTION URL
# ------------------------------------------------------------------------------

resource "aws_lambda_function_url" "main" {
  count = var.create_function_url ? 1 : 0

  function_name      = aws_lambda_function.main.function_name
  authorization_type = var.function_url_authorization_type

  dynamic "cors" {
    for_each = var.function_url_cors != null ? [var.function_url_cors] : []
    content {
      allow_credentials = cors.value.allow_credentials
      allow_headers     = cors.value.allow_headers
      allow_methods     = cors.value.allow_methods
      allow_origins     = cors.value.allow_origins
      expose_headers    = cors.value.expose_headers
      max_age           = cors.value.max_age
    }
  }
}

# ------------------------------------------------------------------------------
# PERMISSIONS (for triggers)
# ------------------------------------------------------------------------------

resource "aws_lambda_permission" "triggers" {
  for_each = var.allowed_triggers

  statement_id       = each.key
  action             = "lambda:InvokeFunction"
  function_name      = aws_lambda_function.main.function_name
  principal          = "${each.value.service}.amazonaws.com"
  source_arn         = each.value.source_arn
  source_account     = each.value.source_account
  event_source_token = each.value.event_source_token
}

# ------------------------------------------------------------------------------
# EVENT SOURCE MAPPINGS
# ------------------------------------------------------------------------------

resource "aws_lambda_event_source_mapping" "main" {
  for_each = var.event_source_mappings

  function_name                      = aws_lambda_function.main.arn
  event_source_arn                   = each.value.event_source_arn
  batch_size                         = each.value.batch_size
  maximum_batching_window_in_seconds = each.value.maximum_batching_window_in_seconds
  enabled                            = each.value.enabled
  starting_position                  = each.value.starting_position
  starting_position_timestamp        = each.value.starting_position_timestamp
  function_response_types            = each.value.function_response_types

  dynamic "filter_criteria" {
    for_each = each.value.filter_criteria != null ? [each.value.filter_criteria] : []
    content {
      dynamic "filter" {
        for_each = filter_criteria.value.filters
        content {
          pattern = filter.value.pattern
        }
      }
    }
  }
}
