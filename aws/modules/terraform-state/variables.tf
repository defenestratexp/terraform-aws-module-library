# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Base name for the state resources (e.g., client name or project). Used to construct bucket and table names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.name)) && length(var.name) >= 3 && length(var.name) <= 32
    error_message = "Name must be 3-32 characters, lowercase alphanumeric and hyphens, cannot start/end with hyphen."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ------------------------------------------------------------------------------

variable "bucket_suffix" {
  description = "Suffix to append to the bucket name. Defaults to 'tfstate'."
  type        = string
  default     = "tfstate"
}

variable "table_suffix" {
  description = "Suffix to append to the DynamoDB table name. Defaults to 'tfstate-lock'."
  type        = string
  default     = "tfstate-lock"
}

variable "enable_versioning" {
  description = "Enable versioning on the S3 bucket. Recommended for state file recovery."
  type        = bool
  default     = true
}

variable "enable_replication" {
  description = "Enable cross-region replication for disaster recovery. Requires replication_region to be set."
  type        = bool
  default     = false
}

variable "replication_region" {
  description = "AWS region for cross-region replication. Required if enable_replication is true."
  type        = string
  default     = ""
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days to retain noncurrent versions of state files. Set to 0 to disable."
  type        = number
  default     = 90
}

variable "kms_key_arn" {
  description = "ARN of KMS key for S3 encryption. If not provided, uses AES256 (SSE-S3)."
  type        = string
  default     = ""
}

variable "force_destroy" {
  description = "Allow destruction of S3 bucket even if it contains objects. Use with caution."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
