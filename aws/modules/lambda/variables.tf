# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "handler" {
  description = "Function entrypoint (e.g., index.handler)"
  type        = string
}

variable "runtime" {
  description = "Runtime environment (e.g., nodejs20.x, python3.12)"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SOURCE CODE
# ------------------------------------------------------------------------------

variable "source_path" {
  description = "Path to source code directory or file (creates zip automatically)"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket containing the deployment package"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of the deployment package"
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "S3 object version of the deployment package"
  type        = string
  default     = null
}

variable "filename" {
  description = "Path to the deployment package zip file"
  type        = string
  default     = null
}

variable "image_uri" {
  description = "ECR image URI for container-based Lambda"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - FUNCTION CONFIGURATION
# ------------------------------------------------------------------------------

variable "description" {
  description = "Description of the function"
  type        = string
  default     = ""
}

variable "memory_size" {
  description = "Memory allocation in MB (128-10240)"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout in seconds (max 900)"
  type        = number
  default     = 3
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrent executions (-1 for unreserved)"
  type        = number
  default     = -1
}

variable "publish" {
  description = "Publish a new version on each update"
  type        = bool
  default     = false
}

variable "architectures" {
  description = "Instruction set architecture (x86_64 or arm64)"
  type        = list(string)
  default     = ["x86_64"]
}

variable "package_type" {
  description = "Deployment package type (Zip or Image)"
  type        = string
  default     = "Zip"
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENVIRONMENT
# ------------------------------------------------------------------------------

variable "environment_variables" {
  description = "Environment variables for the function"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - VPC
# ------------------------------------------------------------------------------

variable "vpc_config" {
  description = "VPC configuration for the function"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - IAM
# ------------------------------------------------------------------------------

variable "role_arn" {
  description = "ARN of the execution role (created if not provided)"
  type        = string
  default     = null
}

variable "create_role" {
  description = "Create the execution IAM role"
  type        = bool
  default     = true
}

variable "role_policies" {
  description = "Map of policy ARNs to attach to the role"
  type        = map(string)
  default     = {}
}

variable "role_inline_policies" {
  description = "Map of inline policies to attach to the role"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LAYERS
# ------------------------------------------------------------------------------

variable "layers" {
  description = "List of Lambda layer ARNs"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LOGGING
# ------------------------------------------------------------------------------

variable "cloudwatch_log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "KMS key ID for log group encryption"
  type        = string
  default     = null
}

variable "logging_config" {
  description = "Logging configuration"
  type = object({
    log_format            = optional(string, "Text")
    application_log_level = optional(string)
    system_log_level      = optional(string)
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TRACING
# ------------------------------------------------------------------------------

variable "tracing_mode" {
  description = "X-Ray tracing mode (Active or PassThrough)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DEAD LETTER QUEUE
# ------------------------------------------------------------------------------

variable "dead_letter_config" {
  description = "Dead letter queue configuration"
  type = object({
    target_arn = string
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - FILE SYSTEM
# ------------------------------------------------------------------------------

variable "file_system_config" {
  description = "EFS file system configuration"
  type = object({
    arn              = string
    local_mount_path = string
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - EPHEMERAL STORAGE
# ------------------------------------------------------------------------------

variable "ephemeral_storage_size" {
  description = "Ephemeral storage size in MB (512-10240)"
  type        = number
  default     = 512
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - FUNCTION URL
# ------------------------------------------------------------------------------

variable "create_function_url" {
  description = "Create a function URL"
  type        = bool
  default     = false
}

variable "function_url_authorization_type" {
  description = "Function URL authorization type (NONE or AWS_IAM)"
  type        = string
  default     = "NONE"
}

variable "function_url_cors" {
  description = "CORS configuration for function URL"
  type = object({
    allow_credentials = optional(bool, false)
    allow_headers     = optional(list(string), ["*"])
    allow_methods     = optional(list(string), ["*"])
    allow_origins     = optional(list(string), ["*"])
    expose_headers    = optional(list(string), [])
    max_age           = optional(number, 0)
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TRIGGERS
# ------------------------------------------------------------------------------

variable "allowed_triggers" {
  description = "Map of triggers to allow invoking this function"
  type = map(object({
    service            = string
    source_arn         = optional(string)
    source_account     = optional(string)
    event_source_token = optional(string)
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - EVENT SOURCE MAPPINGS
# ------------------------------------------------------------------------------

variable "event_source_mappings" {
  description = "Map of event source mappings"
  type = map(object({
    event_source_arn                   = string
    batch_size                         = optional(number)
    maximum_batching_window_in_seconds = optional(number)
    enabled                            = optional(bool, true)
    starting_position                  = optional(string)
    starting_position_timestamp        = optional(string)
    function_response_types            = optional(list(string))
    filter_criteria = optional(object({
      filters = list(object({
        pattern = string
      }))
    }))
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
