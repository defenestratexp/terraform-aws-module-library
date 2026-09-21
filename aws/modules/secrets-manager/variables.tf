# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the secret"
  type        = string

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 512
    error_message = "Secret name must be between 1 and 512 characters."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SECRET VALUE
# ------------------------------------------------------------------------------

variable "secret_string" {
  description = "Secret string value (mutually exclusive with secret_binary)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "secret_binary" {
  description = "Secret binary value (base64 encoded, mutually exclusive with secret_string)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ignore_secret_changes" {
  description = "Ignore changes to secret value after creation"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENCRYPTION
# ------------------------------------------------------------------------------

variable "kms_key_id" {
  description = "KMS key ID for encryption (uses aws/secretsmanager if not specified)"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ROTATION
# ------------------------------------------------------------------------------

variable "enable_rotation" {
  description = "Enable automatic rotation"
  type        = bool
  default     = false
}

variable "rotation_lambda_arn" {
  description = "ARN of the Lambda function for rotation"
  type        = string
  default     = ""
}

variable "rotation_days" {
  description = "Number of days between rotations"
  type        = number
  default     = 30

  validation {
    condition     = var.rotation_days >= 1 && var.rotation_days <= 1000
    error_message = "Rotation days must be between 1 and 1000."
  }
}

variable "rotation_schedule_expression" {
  description = "Cron or rate expression for rotation schedule (overrides rotation_days)"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - REPLICATION
# ------------------------------------------------------------------------------

variable "replica_regions" {
  description = "List of regions for secret replication"
  type = list(object({
    region     = string
    kms_key_id = optional(string, null)
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - POLICY
# ------------------------------------------------------------------------------

variable "policy" {
  description = "Resource policy for the secret"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SETTINGS
# ------------------------------------------------------------------------------

variable "description" {
  description = "Description of the secret"
  type        = string
  default     = ""
}

variable "recovery_window_in_days" {
  description = "Number of days before permanent deletion (0 for immediate, 7-30 otherwise)"
  type        = number
  default     = 30

  validation {
    condition     = var.recovery_window_in_days == 0 || (var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30)
    error_message = "Recovery window must be 0 (immediate) or between 7 and 30 days."
  }
}

variable "force_overwrite_replica_secret" {
  description = "Force overwrite of replicated secrets"
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
