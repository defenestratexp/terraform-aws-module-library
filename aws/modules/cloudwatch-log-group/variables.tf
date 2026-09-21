# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the CloudWatch log group"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LOG GROUP SETTINGS
# ------------------------------------------------------------------------------

variable "retention_in_days" {
  description = "Log retention in days (0 = never expire)"
  type        = number
  default     = 30

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.retention_in_days)
    error_message = "Retention must be one of: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653."
  }
}

variable "kms_key_id" {
  description = "KMS key ARN for log encryption"
  type        = string
  default     = null
}

variable "log_group_class" {
  description = "Log group class (STANDARD or INFREQUENT_ACCESS)"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "INFREQUENT_ACCESS"], var.log_group_class)
    error_message = "Log group class must be STANDARD or INFREQUENT_ACCESS."
  }
}

variable "skip_destroy" {
  description = "Skip destruction of the log group (prevents accidental deletion)"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - METRIC FILTERS
# ------------------------------------------------------------------------------

variable "metric_filters" {
  description = "Map of metric filters to create"
  type = map(object({
    pattern          = string
    metric_name      = string
    metric_namespace = string
    metric_value     = optional(string, "1")
    default_value    = optional(string)
    unit             = optional(string)
    dimensions       = optional(map(string))
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SUBSCRIPTION FILTERS
# ------------------------------------------------------------------------------

variable "subscription_filters" {
  description = "Map of subscription filters to create"
  type = map(object({
    destination_arn = string
    filter_pattern  = optional(string, "")
    role_arn        = optional(string)
    distribution    = optional(string)
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
