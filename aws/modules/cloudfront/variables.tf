# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "origin" {
  description = "Primary origin configuration"
  type = object({
    domain_name = string
    origin_id   = optional(string, "primary")

    # S3 origin settings
    origin_access_control_id = optional(string, null)
    s3_origin_config = optional(object({
      origin_access_identity = string
    }), null)

    # Custom origin settings
    custom_origin_config = optional(object({
      http_port                = optional(number, 80)
      https_port               = optional(number, 443)
      origin_protocol_policy   = optional(string, "https-only")
      origin_ssl_protocols     = optional(list(string), ["TLSv1.2"])
      origin_keepalive_timeout = optional(number, 5)
      origin_read_timeout      = optional(number, 30)
    }), null)

    # Custom headers
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])

    # Origin shield
    origin_shield = optional(object({
      enabled              = bool
      origin_shield_region = string
    }), null)

    origin_path = optional(string, "")
  })
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ADDITIONAL ORIGINS
# ------------------------------------------------------------------------------

variable "additional_origins" {
  description = "Additional origin configurations"
  type = list(object({
    domain_name              = string
    origin_id                = string
    origin_access_control_id = optional(string, null)
    s3_origin_config = optional(object({
      origin_access_identity = string
    }), null)
    custom_origin_config = optional(object({
      http_port                = optional(number, 80)
      https_port               = optional(number, 443)
      origin_protocol_policy   = optional(string, "https-only")
      origin_ssl_protocols     = optional(list(string), ["TLSv1.2"])
      origin_keepalive_timeout = optional(number, 5)
      origin_read_timeout      = optional(number, 30)
    }), null)
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
    origin_path = optional(string, "")
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DEFAULT CACHE BEHAVIOR
# ------------------------------------------------------------------------------

variable "default_cache_behavior" {
  description = "Default cache behavior settings"
  type = object({
    allowed_methods            = optional(list(string), ["GET", "HEAD"])
    cached_methods             = optional(list(string), ["GET", "HEAD"])
    compress                   = optional(bool, true)
    viewer_protocol_policy     = optional(string, "redirect-to-https")
    cache_policy_id            = optional(string, null)
    origin_request_policy_id   = optional(string, null)
    response_headers_policy_id = optional(string, null)

    # Legacy TTL settings (used if cache_policy_id not set)
    min_ttl     = optional(number, 0)
    default_ttl = optional(number, 86400)
    max_ttl     = optional(number, 31536000)

    # Forwarded values (legacy, used if cache_policy_id not set)
    forward_cookies         = optional(string, "none")
    forward_headers         = optional(list(string), [])
    forward_query_string    = optional(bool, false)
    query_string_cache_keys = optional(list(string), [])

    # Function associations
    function_associations = optional(list(object({
      event_type   = string
      function_arn = string
    })), [])

    # Lambda@Edge associations
    lambda_function_associations = optional(list(object({
      event_type   = string
      lambda_arn   = string
      include_body = optional(bool, false)
    })), [])
  })
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ORDERED CACHE BEHAVIORS
# ------------------------------------------------------------------------------

variable "ordered_cache_behaviors" {
  description = "Ordered cache behaviors for path patterns"
  type = list(object({
    path_pattern               = string
    target_origin_id           = string
    allowed_methods            = optional(list(string), ["GET", "HEAD"])
    cached_methods             = optional(list(string), ["GET", "HEAD"])
    compress                   = optional(bool, true)
    viewer_protocol_policy     = optional(string, "redirect-to-https")
    cache_policy_id            = optional(string, null)
    origin_request_policy_id   = optional(string, null)
    response_headers_policy_id = optional(string, null)
    min_ttl                    = optional(number, 0)
    default_ttl                = optional(number, 86400)
    max_ttl                    = optional(number, 31536000)
    forward_cookies            = optional(string, "none")
    forward_headers            = optional(list(string), [])
    forward_query_string       = optional(bool, false)
    function_associations = optional(list(object({
      event_type   = string
      function_arn = string
    })), [])
    lambda_function_associations = optional(list(object({
      event_type   = string
      lambda_arn   = string
      include_body = optional(bool, false)
    })), [])
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SSL/TLS
# ------------------------------------------------------------------------------

variable "aliases" {
  description = "List of CNAMEs (alternate domain names)"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS (must be in us-east-1)"
  type        = string
  default     = ""
}

variable "minimum_protocol_version" {
  description = "Minimum TLS protocol version"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "ssl_support_method" {
  description = "SSL support method (sni-only or vip)"
  type        = string
  default     = "sni-only"
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SETTINGS
# ------------------------------------------------------------------------------

variable "enabled" {
  description = "Enable the distribution"
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Enable IPv6"
  type        = bool
  default     = true
}

variable "comment" {
  description = "Comment for the distribution"
  type        = string
  default     = ""
}

variable "default_root_object" {
  description = "Default root object (e.g., index.html)"
  type        = string
  default     = ""
}

variable "price_class" {
  description = "Price class (PriceClass_All, PriceClass_200, PriceClass_100)"
  type        = string
  default     = "PriceClass_100"
}

variable "http_version" {
  description = "HTTP version (http1.1, http2, http2and3, http3)"
  type        = string
  default     = "http2and3"
}

variable "web_acl_id" {
  description = "WAF Web ACL ID"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CUSTOM ERROR RESPONSES
# ------------------------------------------------------------------------------

variable "custom_error_responses" {
  description = "Custom error response configurations"
  type = list(object({
    error_code            = number
    response_code         = optional(number, null)
    response_page_path    = optional(string, null)
    error_caching_min_ttl = optional(number, 300)
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - RESTRICTIONS
# ------------------------------------------------------------------------------

variable "geo_restriction_type" {
  description = "Geo restriction type (none, whitelist, blacklist)"
  type        = string
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "List of country codes for geo restriction"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LOGGING
# ------------------------------------------------------------------------------

variable "logging_config" {
  description = "Access logging configuration"
  type = object({
    bucket          = string
    prefix          = optional(string, "")
    include_cookies = optional(bool, false)
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
