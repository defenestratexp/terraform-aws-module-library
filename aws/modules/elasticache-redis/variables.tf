# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "replication_group_id" {
  description = "ID of the replication group"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.replication_group_id)) && length(var.replication_group_id) <= 40
    error_message = "Replication group ID must start with a letter, contain only lowercase letters, numbers, and hyphens, and be max 40 characters."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENGINE
# ------------------------------------------------------------------------------

variable "engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"
}

variable "node_type" {
  description = "Node type (e.g., cache.t3.micro, cache.r6g.large)"
  type        = string
  default     = "cache.t3.micro"
}

variable "port" {
  description = "Port number"
  type        = number
  default     = 6379
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CLUSTER
# ------------------------------------------------------------------------------

variable "num_cache_clusters" {
  description = "Number of cache clusters (nodes) in the replication group"
  type        = number
  default     = 1

  validation {
    condition     = var.num_cache_clusters >= 1 && var.num_cache_clusters <= 6
    error_message = "Number of cache clusters must be between 1 and 6."
  }
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover (requires num_cache_clusters >= 2)"
  type        = bool
  default     = false
}

variable "multi_az_enabled" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CLUSTER MODE
# ------------------------------------------------------------------------------

variable "cluster_mode_enabled" {
  description = "Enable cluster mode (sharding)"
  type        = bool
  default     = false
}

variable "num_node_groups" {
  description = "Number of node groups (shards) for cluster mode"
  type        = number
  default     = 1
}

variable "replicas_per_node_group" {
  description = "Number of replicas per node group for cluster mode"
  type        = number
  default     = 1
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - NETWORKING
# ------------------------------------------------------------------------------

variable "subnet_ids" {
  description = "List of subnet IDs for the subnet group"
  type        = list(string)
  default     = []
}

variable "subnet_group_name" {
  description = "Name of an existing subnet group"
  type        = string
  default     = ""
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENCRYPTION
# ------------------------------------------------------------------------------

variable "at_rest_encryption_enabled" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Enable encryption in transit"
  type        = bool
  default     = true
}

variable "transit_encryption_mode" {
  description = "Transit encryption mode (required or preferred)"
  type        = string
  default     = "required"

  validation {
    condition     = contains(["required", "preferred"], var.transit_encryption_mode)
    error_message = "Transit encryption mode must be required or preferred."
  }
}

variable "kms_key_id" {
  description = "KMS key ID for at-rest encryption"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - AUTH
# ------------------------------------------------------------------------------

variable "auth_token" {
  description = "Auth token (password) for Redis AUTH"
  type        = string
  default     = ""
  sensitive   = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - PARAMETERS
# ------------------------------------------------------------------------------

variable "parameter_group_name" {
  description = "Name of an existing parameter group"
  type        = string
  default     = ""
}

variable "parameter_group_family" {
  description = "Parameter group family (e.g., redis7)"
  type        = string
  default     = ""
}

variable "parameters" {
  description = "List of parameters"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - MAINTENANCE
# ------------------------------------------------------------------------------

variable "maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "snapshot_window" {
  description = "Daily time range for snapshots"
  type        = string
  default     = "03:00-04:00"
}

variable "snapshot_retention_limit" {
  description = "Number of days to retain snapshots (0 to disable)"
  type        = number
  default     = 0
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply changes immediately"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - NOTIFICATIONS
# ------------------------------------------------------------------------------

variable "notification_topic_arn" {
  description = "ARN of an SNS topic for notifications"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LOGGING
# ------------------------------------------------------------------------------

variable "log_delivery_configuration" {
  description = "Log delivery configuration"
  type = list(object({
    destination      = string
    destination_type = string # cloudwatch-logs or kinesis-firehose
    log_format       = string # text or json
    log_type         = string # slow-log or engine-log
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
