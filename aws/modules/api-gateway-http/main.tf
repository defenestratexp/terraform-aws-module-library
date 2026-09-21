# ------------------------------------------------------------------------------
# API GATEWAY HTTP API MODULE
# Creates an HTTP API (API Gateway v2) with routes, stages, and custom domains
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "api-gateway-http"
  }

  tags = merge(local.default_tags, var.tags)

  # Default access log format
  default_log_format = jsonencode({
    requestId         = "$context.requestId"
    ip                = "$context.identity.sourceIp"
    requestTime       = "$context.requestTime"
    httpMethod        = "$context.httpMethod"
    routeKey          = "$context.routeKey"
    status            = "$context.status"
    protocol          = "$context.protocol"
    responseLength    = "$context.responseLength"
    integrationError  = "$context.integrationErrorMessage"
    integrationStatus = "$context.integrationStatus"
  })
}

# ------------------------------------------------------------------------------
# HTTP API
# ------------------------------------------------------------------------------

resource "aws_apigatewayv2_api" "main" {
  name          = var.name
  description   = var.description
  protocol_type = var.protocol_type
  version       = var.api_version

  disable_execute_api_endpoint = var.disable_execute_api_endpoint

  dynamic "cors_configuration" {
    for_each = var.cors_configuration != null ? [var.cors_configuration] : []
    content {
      allow_origins     = cors_configuration.value.allow_origins
      allow_methods     = cors_configuration.value.allow_methods
      allow_headers     = cors_configuration.value.allow_headers
      expose_headers    = cors_configuration.value.expose_headers
      max_age           = cors_configuration.value.max_age
      allow_credentials = cors_configuration.value.allow_credentials
    }
  }

  tags = merge(local.tags, {
    Name = var.name
  })
}

# ------------------------------------------------------------------------------
# VPC LINKS
# ------------------------------------------------------------------------------

resource "aws_apigatewayv2_vpc_link" "main" {
  for_each = var.vpc_links

  name               = each.key
  subnet_ids         = each.value.subnet_ids
  security_group_ids = each.value.security_group_ids

  tags = merge(local.tags, {
    Name = each.key
  })
}

# ------------------------------------------------------------------------------
# AUTHORIZERS
# ------------------------------------------------------------------------------

resource "aws_apigatewayv2_authorizer" "main" {
  for_each = var.authorizers

  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = each.value.authorizer_type
  name             = each.value.name != null ? each.value.name : each.key
  identity_sources = each.value.identity_sources

  authorizer_uri                    = each.value.authorizer_uri
  authorizer_payload_format_version = each.value.authorizer_type == "REQUEST" ? each.value.authorizer_payload_format_version : null
  authorizer_result_ttl_in_seconds  = each.value.authorizer_result_ttl_in_seconds
  enable_simple_responses           = each.value.authorizer_type == "REQUEST" ? each.value.enable_simple_responses : null

  dynamic "jwt_configuration" {
    for_each = each.value.jwt_configuration != null ? [each.value.jwt_configuration] : []
    content {
      audience = jwt_configuration.value.audience
      issuer   = jwt_configuration.value.issuer
    }
  }
}

# ------------------------------------------------------------------------------
# INTEGRATIONS
# ------------------------------------------------------------------------------

resource "aws_apigatewayv2_integration" "main" {
  for_each = var.routes

  api_id           = aws_apigatewayv2_api.main.id
  integration_type = each.value.integration_type

  integration_uri        = each.value.integration_uri
  integration_method     = each.value.integration_method
  payload_format_version = each.value.payload_format_version
  timeout_milliseconds   = each.value.timeout_milliseconds
}

# ------------------------------------------------------------------------------
# ROUTES
# ------------------------------------------------------------------------------

resource "aws_apigatewayv2_route" "main" {
  for_each = var.routes

  api_id    = aws_apigatewayv2_api.main.id
  route_key = each.key
  target    = "integrations/${aws_apigatewayv2_integration.main[each.key].id}"

  authorization_type = each.value.authorization_type
  authorizer_id      = each.value.authorizer_id != null ? aws_apigatewayv2_authorizer.main[each.value.authorizer_id].id : null
  api_key_required   = each.value.api_key_required
}

# ------------------------------------------------------------------------------
# STAGES
# ------------------------------------------------------------------------------

resource "aws_apigatewayv2_stage" "main" {
  for_each = var.stages

  api_id      = aws_apigatewayv2_api.main.id
  name        = each.key
  description = each.value.description
  auto_deploy = each.value.auto_deploy

  stage_variables = each.value.stage_variables

  dynamic "access_log_settings" {
    for_each = each.value.access_log_settings != null ? [each.value.access_log_settings] : []
    content {
      destination_arn = access_log_settings.value.destination_arn
      format          = access_log_settings.value.format != null ? access_log_settings.value.format : local.default_log_format
    }
  }

  dynamic "default_route_settings" {
    for_each = each.value.default_route_settings != null ? [each.value.default_route_settings] : []
    content {
      detailed_metrics_enabled = default_route_settings.value.detailed_metrics_enabled
      logging_level            = default_route_settings.value.logging_level
      throttling_burst_limit   = default_route_settings.value.throttling_burst_limit
      throttling_rate_limit    = default_route_settings.value.throttling_rate_limit
    }
  }

  dynamic "route_settings" {
    for_each = each.value.route_settings
    content {
      route_key                = route_settings.key
      detailed_metrics_enabled = route_settings.value.detailed_metrics_enabled
      logging_level            = route_settings.value.logging_level
      throttling_burst_limit   = route_settings.value.throttling_burst_limit
      throttling_rate_limit    = route_settings.value.throttling_rate_limit
    }
  }

  tags = merge(local.tags, {
    Name = "${var.name}-${each.key}"
  })
}

# ------------------------------------------------------------------------------
# CUSTOM DOMAIN NAMES
# ------------------------------------------------------------------------------

resource "aws_apigatewayv2_domain_name" "main" {
  for_each = var.domain_names

  domain_name = each.key

  domain_name_configuration {
    certificate_arn = each.value.certificate_arn
    endpoint_type   = each.value.endpoint_type
    security_policy = each.value.security_policy
  }

  tags = merge(local.tags, {
    Name = each.key
  })
}

resource "aws_apigatewayv2_api_mapping" "main" {
  for_each = merge([
    for domain, config in var.domain_names : {
      for mapping in config.api_mappings : "${domain}-${mapping.stage_name}" => {
        domain_name     = domain
        stage_name      = mapping.stage_name
        api_mapping_key = mapping.api_mapping_key
      }
    }
  ]...)

  api_id          = aws_apigatewayv2_api.main.id
  domain_name     = aws_apigatewayv2_domain_name.main[each.value.domain_name].domain_name
  stage           = aws_apigatewayv2_stage.main[each.value.stage_name].id
  api_mapping_key = each.value.api_mapping_key
}
