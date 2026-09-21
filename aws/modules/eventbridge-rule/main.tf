# ------------------------------------------------------------------------------
# EVENTBRIDGE RULE MODULE
# Creates an EventBridge rule with targets
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "eventbridge-rule"
  }

  tags = merge(local.default_tags, var.tags)

  # Identify Lambda targets for permission creation
  lambda_targets = var.create_lambda_permissions ? {
    for k, v in var.targets : k => v
    if can(regex("^arn:aws:lambda:", v.arn))
  } : {}
}

# ------------------------------------------------------------------------------
# EVENTBRIDGE RULE
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "main" {
  name        = var.name
  description = var.description

  event_bus_name      = var.event_bus_name
  schedule_expression = var.schedule_expression
  event_pattern       = var.event_pattern
  is_enabled          = var.state == null ? var.is_enabled : null
  state               = var.state

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# EVENTBRIDGE TARGETS
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_event_target" "main" {
  for_each = var.targets

  rule           = aws_cloudwatch_event_rule.main.name
  event_bus_name = var.event_bus_name
  target_id      = each.key
  arn            = each.value.arn
  role_arn       = each.value.role_arn
  input          = each.value.input
  input_path     = each.value.input_path

  dynamic "input_transformer" {
    for_each = each.value.input_transformer != null ? [each.value.input_transformer] : []
    content {
      input_paths    = input_transformer.value.input_paths
      input_template = input_transformer.value.input_template
    }
  }

  dynamic "retry_policy" {
    for_each = each.value.retry_policy != null ? [each.value.retry_policy] : []
    content {
      maximum_event_age_in_seconds = retry_policy.value.maximum_event_age_in_seconds
      maximum_retry_attempts       = retry_policy.value.maximum_retry_attempts
    }
  }

  dynamic "dead_letter_config" {
    for_each = each.value.dead_letter_config != null ? [each.value.dead_letter_config] : []
    content {
      arn = dead_letter_config.value.arn
    }
  }

  dynamic "ecs_target" {
    for_each = each.value.ecs_target != null ? [each.value.ecs_target] : []
    content {
      task_definition_arn     = ecs_target.value.task_definition_arn
      task_count              = ecs_target.value.task_count
      launch_type             = ecs_target.value.launch_type
      platform_version        = ecs_target.value.platform_version
      group                   = ecs_target.value.group
      enable_execute_command  = ecs_target.value.enable_execute_command
      enable_ecs_managed_tags = ecs_target.value.enable_ecs_managed_tags
      propagate_tags          = ecs_target.value.propagate_tags

      dynamic "network_configuration" {
        for_each = ecs_target.value.network_configuration != null ? [ecs_target.value.network_configuration] : []
        content {
          subnets          = network_configuration.value.subnets
          security_groups  = network_configuration.value.security_groups
          assign_public_ip = network_configuration.value.assign_public_ip
        }
      }

      dynamic "capacity_provider_strategy" {
        for_each = ecs_target.value.capacity_provider_strategy != null ? ecs_target.value.capacity_provider_strategy : []
        content {
          capacity_provider = capacity_provider_strategy.value.capacity_provider
          weight            = capacity_provider_strategy.value.weight
          base              = capacity_provider_strategy.value.base
        }
      }
    }
  }

  dynamic "sqs_target" {
    for_each = each.value.sqs_target != null ? [each.value.sqs_target] : []
    content {
      message_group_id = sqs_target.value.message_group_id
    }
  }

  dynamic "kinesis_target" {
    for_each = each.value.kinesis_target != null ? [each.value.kinesis_target] : []
    content {
      partition_key_path = kinesis_target.value.partition_key_path
    }
  }

  dynamic "http_target" {
    for_each = each.value.http_target != null ? [each.value.http_target] : []
    content {
      path_parameter_values   = http_target.value.path_parameter_values
      query_string_parameters = http_target.value.query_string_parameters
      header_parameters       = http_target.value.header_parameters
    }
  }

  dynamic "batch_target" {
    for_each = each.value.batch_target != null ? [each.value.batch_target] : []
    content {
      job_definition = batch_target.value.job_definition
      job_name       = batch_target.value.job_name
      array_size     = batch_target.value.array_size
      job_attempts   = batch_target.value.job_attempts
    }
  }
}

# ------------------------------------------------------------------------------
# LAMBDA PERMISSIONS
# ------------------------------------------------------------------------------

resource "aws_lambda_permission" "main" {
  for_each = local.lambda_targets

  statement_id  = "EventBridge-${var.name}-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.main.arn
}
