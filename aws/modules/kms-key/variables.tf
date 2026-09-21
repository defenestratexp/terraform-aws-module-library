# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "alias" {
  description = "Alias for the KMS key (will be prefixed with alias/)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9/_-]+$", var.alias)) && length(var.alias) <= 256
    error_message = "Alias must be alphanumeric with /_- and max 256 characters."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - KEY SETTINGS
# ------------------------------------------------------------------------------

variable "description" {
  description = "Description of the KMS key"
  type        = string
  default     = ""
}

variable "key_usage" {
  description = "Key usage (ENCRYPT_DECRYPT, SIGN_VERIFY, or GENERATE_VERIFY_MAC)"
  type        = string
  default     = "ENCRYPT_DECRYPT"

  validation {
    condition     = contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY", "GENERATE_VERIFY_MAC"], var.key_usage)
    error_message = "Key usage must be ENCRYPT_DECRYPT, SIGN_VERIFY, or GENERATE_VERIFY_MAC."
  }
}

variable "customer_master_key_spec" {
  description = "Key spec (SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, etc.)"
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

variable "multi_region" {
  description = "Create a multi-region key"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - KEY POLICY
# ------------------------------------------------------------------------------

variable "policy" {
  description = "Custom key policy JSON (overrides default policy)"
  type        = string
  default     = ""
}

variable "enable_default_policy" {
  description = "Enable default key policy that allows root account full access"
  type        = bool
  default     = true
}

variable "key_administrators" {
  description = "List of IAM ARNs that can administer the key"
  type        = list(string)
  default     = []
}

variable "key_users" {
  description = "List of IAM ARNs that can use the key for cryptographic operations"
  type        = list(string)
  default     = []
}

variable "key_service_users" {
  description = "List of IAM ARNs that can grant AWS services access to the key"
  type        = list(string)
  default     = []
}

variable "key_grants" {
  description = "List of service principals that can use the key via grants"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ROTATION AND DELETION
# ------------------------------------------------------------------------------

variable "enable_key_rotation" {
  description = "Enable automatic key rotation (only for symmetric keys)"
  type        = bool
  default     = true
}

variable "rotation_period_in_days" {
  description = "Rotation period in days (90-2560)"
  type        = number
  default     = 365

  validation {
    condition     = var.rotation_period_in_days >= 90 && var.rotation_period_in_days <= 2560
    error_message = "Rotation period must be between 90 and 2560 days."
  }
}

variable "deletion_window_in_days" {
  description = "Waiting period before key deletion (7-30 days)"
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Deletion window must be between 7 and 30 days."
  }
}

variable "is_enabled" {
  description = "Whether the key is enabled"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
