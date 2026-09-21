# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the IAM policy"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9+=,.@_-]+$", var.name)) && length(var.name) <= 128
    error_message = "Policy name must be alphanumeric with +=,.@_- and max 128 characters."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - POLICY DOCUMENT
# ------------------------------------------------------------------------------

variable "policy" {
  description = "JSON policy document (use this OR statements, not both)"
  type        = string
  default     = ""
}

variable "statements" {
  description = "List of policy statements (alternative to policy)"
  type = list(object({
    sid       = optional(string, null)
    effect    = optional(string, "Allow")
    actions   = list(string)
    resources = list(string)
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SETTINGS
# ------------------------------------------------------------------------------

variable "description" {
  description = "Description of the policy"
  type        = string
  default     = ""
}

variable "path" {
  description = "Path for the policy"
  type        = string
  default     = "/"
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
