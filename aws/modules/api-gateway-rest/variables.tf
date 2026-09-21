# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the REST API"
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

variable "api_key_source" {
  description = "Source for API key (HEADER or AUTHORIZER)"
  type        = string
  default     = "HEADER"
}

variable "binary_media_types" {
  description = "List of binary media types"
  type        = list(string)
  default     = []
}

variable "minimum_compression_size" {
  description = "Minimum response size to compress (-1 to disable)"
  type        = number
  default     = -1
}

variable "disable_execute_api_endpoint" {
  description = "Disable the default execute-api endpoint"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENDPOINT CONFIGURATION
# ------------------------------------------------------------------------------

variable "endpoint_type" {
  description = "Endpoint type (EDGE, REGIONAL, or PRIVATE)"
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["EDGE", "REGIONAL", "PRIVATE"], var.endpoint_type)
    error_message = "endpoint_type must be EDGE, REGIONAL, or PRIVATE."
  }
}

variable "vpc_endpoint_ids" {
  description = "VPC endpoint IDs for PRIVATE endpoint type"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - OPENAPI SPEC
# ------------------------------------------------------------------------------

variable "openapi_spec" {
  description = "OpenAPI specification (JSON or YAML string)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - STAGES
# ------------------------------------------------------------------------------

variable "stages" {
  description = "Map of stages to create"
  type = map(object({
    description           = optional(string, "")
    cache_cluster_enabled = optional(bool, false)
    cache_cluster_size    = optional(string, "0.5")
    xray_tracing_enabled  = optional(bool, false)
    variables             = optional(map(string), {})
    access_log_settings = optional(object({
      destination_arn = string
      format          = optional(string)
    }))
    canary_settings = optional(object({
      percent_traffic          = number
      stage_variable_overrides = optional(map(string), {})
      use_stage_cache          = optional(bool, false)
    }))
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DEPLOYMENT
# ------------------------------------------------------------------------------

variable "create_deployment" {
  description = "Create a deployment"
  type        = bool
  default     = true
}

variable "deployment_description" {
  description = "Description for the deployment"
  type        = string
  default     = "Managed by Terraform"
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
    base_path       = optional(string)
    stage_name      = string
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - API KEYS
# ------------------------------------------------------------------------------

variable "api_keys" {
  description = "Map of API keys to create"
  type = map(object({
    description = optional(string, "")
    enabled     = optional(bool, true)
    value       = optional(string)
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - USAGE PLANS
# ------------------------------------------------------------------------------

variable "usage_plans" {
  description = "Map of usage plans"
  type = map(object({
    description = optional(string, "")
    quota_settings = optional(object({
      limit  = number
      offset = optional(number, 0)
      period = string
    }))
    throttle_settings = optional(object({
      burst_limit = number
      rate_limit  = number
    }))
    api_stages = optional(list(object({
      stage_name = string
      throttle = optional(map(object({
        burst_limit = number
        rate_limit  = number
      })), {})
    })), [])
    api_key_ids = optional(list(string), [])
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - RESOURCE POLICY
# ------------------------------------------------------------------------------

variable "resource_policy" {
  description = "Resource policy JSON for the API"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CORS
# ------------------------------------------------------------------------------

variable "cors_configuration" {
  description = "Default CORS configuration for the API"
  type = object({
    allow_origins     = list(string)
    allow_methods     = optional(list(string), ["GET", "POST", "PUT", "DELETE", "OPTIONS"])
    allow_headers     = optional(list(string), ["Content-Type", "Authorization", "X-Api-Key"])
    expose_headers    = optional(list(string), [])
    max_age           = optional(number, 7200)
    allow_credentials = optional(bool, false)
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
