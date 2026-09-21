# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the instance profile"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9+=,.@_-]+$", var.name)) && length(var.name) <= 128
    error_message = "Instance profile name must be alphanumeric with +=,.@_- and max 128 characters."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ROLE
# ------------------------------------------------------------------------------

variable "role_arn" {
  description = "ARN of an existing IAM role to use (mutually exclusive with create_role)"
  type        = string
  default     = ""
}

variable "create_role" {
  description = "Create a new IAM role for the instance profile"
  type        = bool
  default     = true
}

variable "trusted_services" {
  description = "List of AWS services that can assume the role (default: ec2)"
  type        = list(string)
  default     = ["ec2.amazonaws.com"]
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the role"
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

variable "path" {
  description = "Path for the instance profile and role"
  type        = string
  default     = "/"
}

variable "permissions_boundary" {
  description = "ARN of the permissions boundary policy for the role"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
