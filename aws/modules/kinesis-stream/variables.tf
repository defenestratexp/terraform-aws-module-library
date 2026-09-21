# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the Kinesis stream"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CAPACITY
# ------------------------------------------------------------------------------

variable "stream_mode" {
  description = "Stream mode (PROVISIONED or ON_DEMAND)"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["PROVISIONED", "ON_DEMAND"], var.stream_mode)
    error_message = "Stream mode must be PROVISIONED or ON_DEMAND."
  }
}

variable "shard_count" {
  description = "Number of shards (required for PROVISIONED mode)"
  type        = number
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - RETENTION
# ------------------------------------------------------------------------------

variable "retention_period" {
  description = "Data retention period in hours (24-8760)"
  type        = number
  default     = 24

  validation {
    condition     = var.retention_period >= 24 && var.retention_period <= 8760
    error_message = "Retention period must be between 24 and 8760 hours."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENCRYPTION
# ------------------------------------------------------------------------------

variable "encryption_type" {
  description = "Encryption type (NONE or KMS)"
  type        = string
  default     = "KMS"

  validation {
    condition     = contains(["NONE", "KMS"], var.encryption_type)
    error_message = "Encryption type must be NONE or KMS."
  }
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (use 'alias/aws/kinesis' for AWS managed key)"
  type        = string
  default     = "alias/aws/kinesis"
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENHANCED CONSUMERS
# ------------------------------------------------------------------------------

variable "consumers" {
  description = "Map of enhanced fan-out consumers to create"
  type = map(object({
    name = string
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
