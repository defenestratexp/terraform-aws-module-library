# ------------------------------------------------------------------------------
# API GATEWAY REST API MODULE
# Creates a REST API Gateway with stages, custom domains, and usage plans
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "api-gateway-rest"
  }

  tags = merge(local.default_tags, var.tags)

  # Default access log format
  default_log_format = jsonencode({
    requestId         = "$context.requestId"
    ip                = "$context.identity.sourceIp"
    caller            = "$context.identity.caller"
    user              = "$context.identity.user"
    requestTime       = "$context.requestTime"
    httpMethod        = "$context.httpMethod"
    resourcePath      = "$context.resourcePath"
    status            = "$context.status"
    protocol          = "$context.protocol"
    responseLength    = "$context.responseLength"
    integrationError  = "$context.integrationErrorMessage"
    integrationStatus = "$context.integrationStatus"
  })
}

# ------------------------------------------------------------------------------
# REST API
# ------------------------------------------------------------------------------

resource "aws_api_gateway_rest_api" "main" {
  name        = var.name
  description = var.description

  api_key_source               = var.api_key_source
  binary_media_types           = var.binary_media_types
  minimum_compression_size     = var.minimum_compression_size >= 0 ? var.minimum_compression_size : null
  disable_execute_api_endpoint = var.disable_execute_api_endpoint

  endpoint_configuration {
    types            = [var.endpoint_type]
    vpc_endpoint_ids = var.endpoint_type == "PRIVATE" ? var.vpc_endpoint_ids : null
  }

  # Import OpenAPI spec if provided
  body = var.openapi_spec

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# RESOURCE POLICY
# ------------------------------------------------------------------------------

resource "aws_api_gateway_rest_api_policy" "main" {
  count = var.resource_policy != null ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.main.id
  policy      = var.resource_policy
}

# ------------------------------------------------------------------------------
# DEPLOYMENT
# ------------------------------------------------------------------------------

resource "aws_api_gateway_deployment" "main" {
  count = var.create_deployment ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.main.id
  description = var.deployment_description

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.main.body,
      var.deployment_description,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# STAGES
# ------------------------------------------------------------------------------

resource "aws_api_gateway_stage" "main" {
  for_each = var.stages

  rest_api_id   = aws_api_gateway_rest_api.main.id
  deployment_id = var.create_deployment ? aws_api_gateway_deployment.main[0].id : null
  stage_name    = each.key

  description           = each.value.description
  cache_cluster_enabled = each.value.cache_cluster_enabled
  cache_cluster_size    = each.value.cache_cluster_enabled ? each.value.cache_cluster_size : null
  xray_tracing_enabled  = each.value.xray_tracing_enabled
  variables             = each.value.variables

  dynamic "access_log_settings" {
    for_each = each.value.access_log_settings != null ? [each.value.access_log_settings] : []
    content {
      destination_arn = access_log_settings.value.destination_arn
      format          = access_log_settings.value.format != null ? access_log_settings.value.format : local.default_log_format
    }
  }

  dynamic "canary_settings" {
    for_each = each.value.canary_settings != null ? [each.value.canary_settings] : []
    content {
      deployment_id            = one(aws_api_gateway_deployment.main[*].id)
      percent_traffic          = canary_settings.value.percent_traffic
      stage_variable_overrides = canary_settings.value.stage_variable_overrides
      use_stage_cache          = canary_settings.value.use_stage_cache
    }
  }

  tags = merge(local.tags, {
    Name = "${var.name}-${each.key}"
  })
}

# ------------------------------------------------------------------------------
# CUSTOM DOMAIN NAMES
# ------------------------------------------------------------------------------

resource "aws_api_gateway_domain_name" "main" {
  for_each = var.domain_names

  domain_name = each.key

  regional_certificate_arn = each.value.endpoint_type == "REGIONAL" ? each.value.certificate_arn : null
  certificate_arn          = each.value.endpoint_type == "EDGE" ? each.value.certificate_arn : null
  security_policy          = each.value.security_policy

  endpoint_configuration {
    types = [each.value.endpoint_type]
  }

  tags = merge(local.tags, {
    Name = each.key
  })
}

resource "aws_api_gateway_base_path_mapping" "main" {
  for_each = var.domain_names

  domain_name = aws_api_gateway_domain_name.main[each.key].domain_name
  api_id      = aws_api_gateway_rest_api.main.id
  stage_name  = each.value.stage_name
  base_path   = each.value.base_path
}

# ------------------------------------------------------------------------------
# API KEYS
# ------------------------------------------------------------------------------

resource "aws_api_gateway_api_key" "main" {
  for_each = var.api_keys

  name        = each.key
  description = each.value.description
  enabled     = each.value.enabled
  value       = each.value.value

  tags = merge(local.tags, {
    Name = each.key
  })
}

# ------------------------------------------------------------------------------
# USAGE PLANS
# ------------------------------------------------------------------------------

resource "aws_api_gateway_usage_plan" "main" {
  for_each = var.usage_plans

  name        = each.key
  description = each.value.description

  dynamic "quota_settings" {
    for_each = each.value.quota_settings != null ? [each.value.quota_settings] : []
    content {
      limit  = quota_settings.value.limit
      offset = quota_settings.value.offset
      period = quota_settings.value.period
    }
  }

  dynamic "throttle_settings" {
    for_each = each.value.throttle_settings != null ? [each.value.throttle_settings] : []
    content {
      burst_limit = throttle_settings.value.burst_limit
      rate_limit  = throttle_settings.value.rate_limit
    }
  }

  dynamic "api_stages" {
    for_each = each.value.api_stages
    content {
      api_id = aws_api_gateway_rest_api.main.id
      stage  = api_stages.value.stage_name

      dynamic "throttle" {
        for_each = api_stages.value.throttle
        content {
          path        = throttle.key
          burst_limit = throttle.value.burst_limit
          rate_limit  = throttle.value.rate_limit
        }
      }
    }
  }

  tags = merge(local.tags, {
    Name = each.key
  })

  depends_on = [aws_api_gateway_stage.main]
}

resource "aws_api_gateway_usage_plan_key" "main" {
  for_each = merge([
    for plan_name, plan in var.usage_plans : {
      for key_id in plan.api_key_ids : "${plan_name}-${key_id}" => {
        usage_plan_id = plan_name
        key_id        = key_id
      }
    }
  ]...)

  key_id        = each.value.key_id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main[each.value.usage_plan_id].id
}
