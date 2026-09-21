# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "cluster_identifier" {
  description = "Unique identifier for the Aurora cluster"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.cluster_identifier)) && length(var.cluster_identifier) <= 63
    error_message = "Cluster identifier must start with a letter, contain only lowercase letters, numbers, and hyphens, and be max 63 characters."
  }
}

variable "engine" {
  description = "Aurora engine (aurora-mysql or aurora-postgresql)"
  type        = string

  validation {
    condition     = contains(["aurora-mysql", "aurora-postgresql"], var.engine)
    error_message = "Engine must be aurora-mysql or aurora-postgresql."
  }
}

variable "engine_version" {
  description = "Aurora engine version"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - INSTANCES
# ------------------------------------------------------------------------------

variable "instance_count" {
  description = "Number of instances in the cluster (including writer)"
  type        = number
  default     = 2

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 16
    error_message = "Instance count must be between 1 and 16."
  }
}

variable "instance_class" {
  description = "Instance class for cluster instances"
  type        = string
  default     = "db.r5.large"
}

variable "serverless_v2_scaling" {
  description = "Serverless v2 scaling configuration"
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - STORAGE
# ------------------------------------------------------------------------------

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ARN for storage encryption"
  type        = string
  default     = ""
}

variable "storage_type" {
  description = "Storage type (aurora or aurora-iopt1)"
  type        = string
  default     = "aurora"

  validation {
    condition     = contains(["aurora", "aurora-iopt1"], var.storage_type)
    error_message = "Storage type must be aurora or aurora-iopt1."
  }
}

variable "allocated_storage" {
  description = "Allocated storage for aurora-iopt1 (in GiB)"
  type        = number
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DATABASE
# ------------------------------------------------------------------------------

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = ""
}

variable "master_username" {
  description = "Master username"
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "Master password (leave empty to use manage_master_user_password)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "manage_master_user_password" {
  description = "Let AWS manage the master password in Secrets Manager"
  type        = bool
  default     = true
}

variable "master_user_secret_kms_key_id" {
  description = "KMS key for Secrets Manager master password"
  type        = string
  default     = ""
}

variable "port" {
  description = "Database port (defaults based on engine)"
  type        = number
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - NETWORKING
# ------------------------------------------------------------------------------

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
  default     = []
}

variable "db_subnet_group_name" {
  description = "Name of an existing DB subnet group"
  type        = string
  default     = ""
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "List of availability zones for the cluster"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - BACKUP AND MAINTENANCE
# ------------------------------------------------------------------------------

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 1 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 1 and 35 days."
  }
}

variable "preferred_backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  description = "Preferred maintenance window (UTC)"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Allow major version upgrades"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply changes immediately"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - MONITORING
# ------------------------------------------------------------------------------

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds"
  type        = number
  default     = 0

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval must be 0, 1, 5, 10, 15, 30, or 60."
  }
}

variable "monitoring_role_arn" {
  description = "ARN of the IAM role for enhanced monitoring"
  type        = string
  default     = ""
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = []
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days"
  type        = number
  default     = 7
}

variable "performance_insights_kms_key_id" {
  description = "KMS key for Performance Insights"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - PARAMETERS
# ------------------------------------------------------------------------------

variable "cluster_parameter_group_name" {
  description = "Name of an existing cluster parameter group"
  type        = string
  default     = ""
}

variable "cluster_parameter_group_family" {
  description = "Cluster parameter group family"
  type        = string
  default     = ""
}

variable "cluster_parameters" {
  description = "List of cluster parameters"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

variable "db_parameter_group_name" {
  description = "Name of an existing DB parameter group"
  type        = string
  default     = ""
}

variable "db_parameter_group_family" {
  description = "DB parameter group family"
  type        = string
  default     = ""
}

variable "db_parameters" {
  description = "List of DB instance parameters"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DELETION
# ------------------------------------------------------------------------------

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "Name of the final snapshot"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - RESTORE
# ------------------------------------------------------------------------------

variable "snapshot_identifier" {
  description = "Snapshot ID to restore from"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - IAM AUTH
# ------------------------------------------------------------------------------

variable "iam_database_authentication_enabled" {
  description = "Enable IAM database authentication"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - GLOBAL DATABASE
# ------------------------------------------------------------------------------

variable "global_cluster_identifier" {
  description = "Global cluster identifier (for global databases)"
  type        = string
  default     = ""
}

variable "enable_global_write_forwarding" {
  description = "Enable global write forwarding"
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
