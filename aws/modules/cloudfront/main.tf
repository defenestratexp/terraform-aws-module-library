# ------------------------------------------------------------------------------
# CLOUDFRONT MODULE
# Creates a CloudFront distribution
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "cloudfront"
  }

  tags = merge(local.default_tags, var.tags)

  # Combine all origins
  all_origins = concat([var.origin], var.additional_origins)

  # Use cache policy or legacy settings
  use_cache_policy = var.default_cache_behavior.cache_policy_id != null
}

# ------------------------------------------------------------------------------
# CLOUDFRONT DISTRIBUTION
# ------------------------------------------------------------------------------

resource "aws_cloudfront_distribution" "main" {
  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  comment             = var.comment
  default_root_object = var.default_root_object != "" ? var.default_root_object : null
  price_class         = var.price_class
  http_version        = var.http_version
  web_acl_id          = var.web_acl_id != "" ? var.web_acl_id : null
  aliases             = var.aliases

  # Origins
  dynamic "origin" {
    for_each = local.all_origins
    content {
      domain_name              = origin.value.domain_name
      origin_id                = origin.value.origin_id
      origin_path              = origin.value.origin_path != "" ? origin.value.origin_path : null
      origin_access_control_id = origin.value.origin_access_control_id

      dynamic "s3_origin_config" {
        for_each = origin.value.s3_origin_config != null ? [origin.value.s3_origin_config] : []
        content {
          origin_access_identity = s3_origin_config.value.origin_access_identity
        }
      }

      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config != null ? [origin.value.custom_origin_config] : []
        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = custom_origin_config.value.origin_keepalive_timeout
          origin_read_timeout      = custom_origin_config.value.origin_read_timeout
        }
      }

      dynamic "custom_header" {
        for_each = origin.value.custom_headers
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }

      dynamic "origin_shield" {
        for_each = origin.value.origin_shield != null ? [origin.value.origin_shield] : []
        content {
          enabled              = origin_shield.value.enabled
          origin_shield_region = origin_shield.value.origin_shield_region
        }
      }
    }
  }

  # Default cache behavior
  default_cache_behavior {
    target_origin_id       = var.origin.origin_id
    allowed_methods        = var.default_cache_behavior.allowed_methods
    cached_methods         = var.default_cache_behavior.cached_methods
    compress               = var.default_cache_behavior.compress
    viewer_protocol_policy = var.default_cache_behavior.viewer_protocol_policy

    # Cache policy (modern approach)
    cache_policy_id            = var.default_cache_behavior.cache_policy_id
    origin_request_policy_id   = var.default_cache_behavior.origin_request_policy_id
    response_headers_policy_id = var.default_cache_behavior.response_headers_policy_id

    # Legacy TTL settings
    min_ttl     = local.use_cache_policy ? null : var.default_cache_behavior.min_ttl
    default_ttl = local.use_cache_policy ? null : var.default_cache_behavior.default_ttl
    max_ttl     = local.use_cache_policy ? null : var.default_cache_behavior.max_ttl

    # Legacy forwarded values
    dynamic "forwarded_values" {
      for_each = local.use_cache_policy ? [] : [1]
      content {
        query_string            = var.default_cache_behavior.forward_query_string
        query_string_cache_keys = var.default_cache_behavior.query_string_cache_keys
        headers                 = var.default_cache_behavior.forward_headers

        cookies {
          forward = var.default_cache_behavior.forward_cookies
        }
      }
    }

    # Function associations
    dynamic "function_association" {
      for_each = var.default_cache_behavior.function_associations
      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }

    # Lambda@Edge associations
    dynamic "lambda_function_association" {
      for_each = var.default_cache_behavior.lambda_function_associations
      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = lambda_function_association.value.include_body
      }
    }
  }

  # Ordered cache behaviors
  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      compress               = ordered_cache_behavior.value.compress
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy

      cache_policy_id            = ordered_cache_behavior.value.cache_policy_id
      origin_request_policy_id   = ordered_cache_behavior.value.origin_request_policy_id
      response_headers_policy_id = ordered_cache_behavior.value.response_headers_policy_id

      min_ttl     = ordered_cache_behavior.value.cache_policy_id != null ? null : ordered_cache_behavior.value.min_ttl
      default_ttl = ordered_cache_behavior.value.cache_policy_id != null ? null : ordered_cache_behavior.value.default_ttl
      max_ttl     = ordered_cache_behavior.value.cache_policy_id != null ? null : ordered_cache_behavior.value.max_ttl

      dynamic "forwarded_values" {
        for_each = ordered_cache_behavior.value.cache_policy_id != null ? [] : [1]
        content {
          query_string = ordered_cache_behavior.value.forward_query_string
          headers      = ordered_cache_behavior.value.forward_headers

          cookies {
            forward = ordered_cache_behavior.value.forward_cookies
          }
        }
      }

      dynamic "function_association" {
        for_each = ordered_cache_behavior.value.function_associations
        content {
          event_type   = function_association.value.event_type
          function_arn = function_association.value.function_arn
        }
      }

      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda_function_associations
        content {
          event_type   = lambda_function_association.value.event_type
          lambda_arn   = lambda_function_association.value.lambda_arn
          include_body = lambda_function_association.value.include_body
        }
      }
    }
  }

  # Custom error responses
  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  # SSL/TLS
  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == ""
    acm_certificate_arn            = var.acm_certificate_arn != "" ? var.acm_certificate_arn : null
    minimum_protocol_version       = var.acm_certificate_arn != "" ? var.minimum_protocol_version : null
    ssl_support_method             = var.acm_certificate_arn != "" ? var.ssl_support_method : null
  }

  # Geo restrictions
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  # Logging
  dynamic "logging_config" {
    for_each = var.logging_config != null ? [var.logging_config] : []
    content {
      bucket          = logging_config.value.bucket
      prefix          = logging_config.value.prefix
      include_cookies = logging_config.value.include_cookies
    }
  }

  tags = local.tags
}
