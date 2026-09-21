# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the IAM role"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9+=,.@_-]+$", var.name)) && length(var.name) <= 64
    error_message = "Role name must be alphanumeric with +=,.@_- and max 64 characters."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ASSUME ROLE
# ------------------------------------------------------------------------------

variable "assume_role_policy" {
  description = "JSON assume role policy document (overrides trusted_* variables)"
  type        = string
  default     = ""
}

variable "trusted_services" {
  description = "List of AWS services that can assume the role"
  type        = list(string)
  default     = []
}

variable "trusted_accounts" {
  description = "List of AWS account IDs that can assume the role"
  type        = list(string)
  default     = []
}

variable "trusted_roles" {
  description = "List of IAM role ARNs that can assume the role"
  type        = list(string)
  default     = []
}

variable "trusted_oidc_providers" {
  description = "List of OIDC provider configurations"
  type = list(object({
    provider_arn = string
    client_ids   = list(string)
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  default = []
}

variable "assume_role_condition" {
  description = "Additional conditions for assume role policy"
  type = list(object({
    test     = string
    variable = string
    values   = list(string)
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - POLICIES
# ------------------------------------------------------------------------------

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policy names to policy documents"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SETTINGS
# ------------------------------------------------------------------------------

variable "description" {
  description = "Description of the role"
  type        = string
  default     = ""
}

variable "path" {
  description = "Path for the role"
  type        = string
  default     = "/"
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds (3600-43200)"
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "Max session duration must be between 3600 and 43200 seconds."
  }
}

variable "permissions_boundary" {
  description = "ARN of the permissions boundary policy"
  type        = string
  default     = ""
}

variable "force_detach_policies" {
  description = "Force detach policies before destroying role"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
