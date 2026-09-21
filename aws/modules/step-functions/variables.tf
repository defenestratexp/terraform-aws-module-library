# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the state machine"
  type        = string
}

variable "definition" {
  description = "State machine definition (Amazon States Language JSON)"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - STATE MACHINE CONFIGURATION
# ------------------------------------------------------------------------------

variable "type" {
  description = "State machine type (STANDARD or EXPRESS)"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "EXPRESS"], var.type)
    error_message = "type must be STANDARD or EXPRESS."
  }
}

variable "publish" {
  description = "Publish a version when creating/updating the state machine"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - IAM
# ------------------------------------------------------------------------------

variable "role_arn" {
  description = "ARN of the IAM role for the state machine (created if not provided)"
  type        = string
  default     = null
}

variable "create_role" {
  description = "Create an IAM role for the state machine"
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
# OPTIONAL VARIABLES - LOGGING
# ------------------------------------------------------------------------------

variable "logging_configuration" {
  description = "Logging configuration"
  type = object({
    level                  = optional(string, "OFF")
    include_execution_data = optional(bool, false)
    log_destination        = optional(string)
  })
  default = null
}

variable "create_log_group" {
  description = "Create a CloudWatch log group for state machine logs"
  type        = bool
  default     = false
}

variable "log_group_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 30
}

variable "log_group_kms_key_id" {
  description = "KMS key ID for log group encryption"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TRACING
# ------------------------------------------------------------------------------

variable "tracing_enabled" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENCRYPTION
# ------------------------------------------------------------------------------

variable "encryption_configuration" {
  description = "Encryption configuration"
  type = object({
    kms_key_id                        = string
    kms_data_key_reuse_period_seconds = optional(number, 300)
    type                              = optional(string, "CUSTOMER_MANAGED_KMS_KEY")
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
