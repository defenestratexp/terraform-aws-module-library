# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the HTTP API"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - API CONFIGURATION
# ------------------------------------------------------------------------------

variable "description" {
  description = "Description of the API"
  type        = string
  default     = ""
}

variable "protocol_type" {
  description = "Protocol type (HTTP or WEBSOCKET)"
  type        = string
  default     = "HTTP"
}

variable "api_version" {
  description = "API version identifier"
  type        = string
  default     = null
}

variable "disable_execute_api_endpoint" {
  description = "Disable the default execute-api endpoint"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CORS
# ------------------------------------------------------------------------------

variable "cors_configuration" {
  description = "CORS configuration"
  type = object({
    allow_origins     = optional(list(string), ["*"])
    allow_methods     = optional(list(string), ["GET", "POST", "PUT", "DELETE", "OPTIONS"])
    allow_headers     = optional(list(string), ["Content-Type", "Authorization"])
    expose_headers    = optional(list(string), [])
    max_age           = optional(number, 7200)
    allow_credentials = optional(bool, false)
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ROUTES AND INTEGRATIONS
# ------------------------------------------------------------------------------

variable "routes" {
  description = "Map of routes and their integrations"
  type = map(object({
    integration_type       = optional(string, "AWS_PROXY")
    integration_uri        = string
    integration_method     = optional(string, "POST")
    payload_format_version = optional(string, "2.0")
    timeout_milliseconds   = optional(number, 30000)
    authorization_type     = optional(string, "NONE")
    authorizer_id          = optional(string)
    api_key_required       = optional(bool, false)
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - AUTHORIZERS
# ------------------------------------------------------------------------------

variable "authorizers" {
  description = "Map of authorizers"
  type = map(object({
    authorizer_type                   = string
    identity_sources                  = optional(list(string), ["$request.header.Authorization"])
    name                              = optional(string)
    authorizer_uri                    = optional(string)
    authorizer_payload_format_version = optional(string, "2.0")
    authorizer_result_ttl_in_seconds  = optional(number, 300)
    enable_simple_responses           = optional(bool, false)
    jwt_configuration = optional(object({
      audience = list(string)
      issuer   = string
    }))
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - STAGES
# ------------------------------------------------------------------------------

variable "stages" {
  description = "Map of stages to create"
  type = map(object({
    description     = optional(string, "")
    auto_deploy     = optional(bool, true)
    stage_variables = optional(map(string), {})
    access_log_settings = optional(object({
      destination_arn = string
      format          = optional(string)
    }))
    default_route_settings = optional(object({
      detailed_metrics_enabled = optional(bool, false)
      logging_level            = optional(string)
      throttling_burst_limit   = optional(number)
      throttling_rate_limit    = optional(number)
    }))
    route_settings = optional(map(object({
      detailed_metrics_enabled = optional(bool, false)
      logging_level            = optional(string)
      throttling_burst_limit   = optional(number)
      throttling_rate_limit    = optional(number)
    })), {})
  }))
  default = {
    "$default" = {
      auto_deploy = true
    }
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CUSTOM DOMAIN
# ------------------------------------------------------------------------------

variable "domain_names" {
  description = "Map of custom domain configurations"
  type = map(object({
    certificate_arn = string
    endpoint_type   = optional(string, "REGIONAL")
    security_policy = optional(string, "TLS_1_2")
    api_mappings = optional(list(object({
      stage_name      = string
      api_mapping_key = optional(string)
    })), [])
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - VPC LINK
# ------------------------------------------------------------------------------

variable "vpc_links" {
  description = "Map of VPC links for private integrations"
  type = map(object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
