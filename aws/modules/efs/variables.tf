# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name for the EFS file system"
  type        = string

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 256
    error_message = "Name must be between 1 and 256 characters."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - PERFORMANCE
# ------------------------------------------------------------------------------

variable "performance_mode" {
  description = "Performance mode (generalPurpose or maxIO)"
  type        = string
  default     = "generalPurpose"

  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.performance_mode)
    error_message = "Performance mode must be generalPurpose or maxIO."
  }
}

variable "throughput_mode" {
  description = "Throughput mode (bursting, provisioned, or elastic)"
  type        = string
  default     = "bursting"

  validation {
    condition     = contains(["bursting", "provisioned", "elastic"], var.throughput_mode)
    error_message = "Throughput mode must be bursting, provisioned, or elastic."
  }
}

variable "provisioned_throughput_in_mibps" {
  description = "Provisioned throughput in MiB/s (required if throughput_mode is provisioned)"
  type        = number
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENCRYPTION
# ------------------------------------------------------------------------------

variable "encrypted" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (uses aws/elasticfilesystem if not specified)"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LIFECYCLE
# ------------------------------------------------------------------------------

variable "lifecycle_policy" {
  description = "Lifecycle policy for transitioning files to IA storage"
  type = object({
    transition_to_ia                    = optional(string, null)
    transition_to_primary_storage_class = optional(string, null)
    transition_to_archive               = optional(string, null)
  })
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - MOUNT TARGETS
# ------------------------------------------------------------------------------

variable "subnet_ids" {
  description = "List of subnet IDs for mount targets"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs for mount targets"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ACCESS POINTS
# ------------------------------------------------------------------------------

variable "access_points" {
  description = "Map of access point configurations"
  type = map(object({
    posix_user = optional(object({
      gid            = number
      uid            = number
      secondary_gids = optional(list(number), [])
    }), null)
    root_directory = optional(object({
      path = string
      creation_info = optional(object({
        owner_gid   = number
        owner_uid   = number
        permissions = string
      }), null)
    }), null)
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - BACKUP
# ------------------------------------------------------------------------------

variable "enable_backup" {
  description = "Enable automatic backups via AWS Backup"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - FILE SYSTEM POLICY
# ------------------------------------------------------------------------------

variable "file_system_policy" {
  description = "JSON policy document for the file system"
  type        = string
  default     = ""
}

variable "deny_nonsecure_transport" {
  description = "Deny access via non-TLS connections"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
