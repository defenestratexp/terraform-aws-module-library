# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the IAM user"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9+=,.@_-]+$", var.name)) && length(var.name) <= 64
    error_message = "User name must be alphanumeric with +=,.@_- and max 64 characters."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ACCESS KEYS
# ------------------------------------------------------------------------------

variable "create_access_key" {
  description = "Create an access key for the user"
  type        = bool
  default     = false
}

variable "access_key_status" {
  description = "Status of the access key (Active or Inactive)"
  type        = string
  default     = "Active"

  validation {
    condition     = contains(["Active", "Inactive"], var.access_key_status)
    error_message = "Access key status must be Active or Inactive."
  }
}

variable "pgp_key" {
  description = "PGP key to encrypt the secret access key (base64-encoded or keybase:username)"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LOGIN PROFILE
# ------------------------------------------------------------------------------

variable "create_login_profile" {
  description = "Create a login profile for console access"
  type        = bool
  default     = false
}

variable "password_length" {
  description = "Length of the generated password"
  type        = number
  default     = 20
}

variable "password_reset_required" {
  description = "Require password reset on first login"
  type        = bool
  default     = true
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
# OPTIONAL VARIABLES - GROUPS
# ------------------------------------------------------------------------------

variable "groups" {
  description = "List of IAM groups to add the user to"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SETTINGS
# ------------------------------------------------------------------------------

variable "path" {
  description = "Path for the user"
  type        = string
  default     = "/"
}

variable "permissions_boundary" {
  description = "ARN of the permissions boundary policy"
  type        = string
  default     = ""
}

variable "force_destroy" {
  description = "Force destroy user even if it has non-Terraform-managed access keys"
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
