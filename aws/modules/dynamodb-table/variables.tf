# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the DynamoDB table"
  type        = string

  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 255
    error_message = "Table name must be between 3 and 255 characters."
  }
}

variable "hash_key" {
  description = "Attribute to use as the hash (partition) key"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - KEYS
# ------------------------------------------------------------------------------

variable "range_key" {
  description = "Attribute to use as the range (sort) key"
  type        = string
  default     = ""
}

variable "attributes" {
  description = "List of attribute definitions"
  type = list(object({
    name = string
    type = string # S, N, or B
  }))
  default = []

  validation {
    condition = alltrue([
      for attr in var.attributes : contains(["S", "N", "B"], attr.type)
    ])
    error_message = "Attribute type must be S (String), N (Number), or B (Binary)."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - BILLING
# ------------------------------------------------------------------------------

variable "billing_mode" {
  description = "Billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "Billing mode must be PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "read_capacity" {
  description = "Read capacity units (for PROVISIONED mode)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units (for PROVISIONED mode)"
  type        = number
  default     = 5
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - GLOBAL SECONDARY INDEXES
# ------------------------------------------------------------------------------

variable "global_secondary_indexes" {
  description = "List of global secondary indexes"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string, null)
    projection_type    = optional(string, "ALL")
    non_key_attributes = optional(list(string), [])
    read_capacity      = optional(number, null)
    write_capacity     = optional(number, null)
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LOCAL SECONDARY INDEXES
# ------------------------------------------------------------------------------

variable "local_secondary_indexes" {
  description = "List of local secondary indexes"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = optional(string, "ALL")
    non_key_attributes = optional(list(string), [])
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TTL
# ------------------------------------------------------------------------------

variable "ttl_enabled" {
  description = "Enable TTL"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Name of the TTL attribute"
  type        = string
  default     = "ttl"
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - STREAMS
# ------------------------------------------------------------------------------

variable "stream_enabled" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES)"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"

  validation {
    condition     = contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "Stream view type must be KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, or NEW_AND_OLD_IMAGES."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENCRYPTION
# ------------------------------------------------------------------------------

variable "server_side_encryption_enabled" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "server_side_encryption_kms_key_arn" {
  description = "KMS key ARN for server-side encryption"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - POINT-IN-TIME RECOVERY
# ------------------------------------------------------------------------------

variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - GLOBAL TABLE
# ------------------------------------------------------------------------------

variable "replica_regions" {
  description = "List of regions for global table replicas"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TABLE CLASS
# ------------------------------------------------------------------------------

variable "table_class" {
  description = "Table class (STANDARD or STANDARD_INFREQUENT_ACCESS)"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "Table class must be STANDARD or STANDARD_INFREQUENT_ACCESS."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DELETION PROTECTION
# ------------------------------------------------------------------------------

variable "deletion_protection_enabled" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - AUTOSCALING
# ------------------------------------------------------------------------------

variable "autoscaling_enabled" {
  description = "Enable autoscaling (only for PROVISIONED mode)"
  type        = bool
  default     = false
}

variable "autoscaling_read" {
  description = "Read capacity autoscaling configuration"
  type = object({
    target_value       = optional(number, 70)
    min_capacity       = optional(number, 5)
    max_capacity       = optional(number, 100)
    scale_in_cooldown  = optional(number, 60)
    scale_out_cooldown = optional(number, 60)
  })
  default = {}
}

variable "autoscaling_write" {
  description = "Write capacity autoscaling configuration"
  type = object({
    target_value       = optional(number, 70)
    min_capacity       = optional(number, 5)
    max_capacity       = optional(number, 100)
    scale_in_cooldown  = optional(number, 60)
    scale_out_cooldown = optional(number, 60)
  })
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
