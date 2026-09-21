# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "cluster_identifier" {
  description = "Identifier for the Redshift cluster"
  type        = string
}

variable "node_type" {
  description = "Node type for the cluster (e.g., dc2.large, ra3.xlplus)"
  type        = string
}

variable "master_username" {
  description = "Master username for the cluster"
  type        = string
}

variable "master_password" {
  description = "Master password for the cluster"
  type        = string
  sensitive   = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CLUSTER SIZE
# ------------------------------------------------------------------------------

variable "cluster_type" {
  description = "Cluster type (single-node or multi-node)"
  type        = string
  default     = "single-node"

  validation {
    condition     = contains(["single-node", "multi-node"], var.cluster_type)
    error_message = "Cluster type must be single-node or multi-node."
  }
}

variable "number_of_nodes" {
  description = "Number of nodes (required for multi-node clusters)"
  type        = number
  default     = 1
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DATABASE
# ------------------------------------------------------------------------------

variable "database_name" {
  description = "Name of the default database"
  type        = string
  default     = "dev"
}

variable "port" {
  description = "Port number for the cluster"
  type        = number
  default     = 5439
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - NETWORKING
# ------------------------------------------------------------------------------

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
  default     = []
}

variable "cluster_subnet_group_name" {
  description = "Name of the cluster subnet group"
  type        = string
  default     = null
}

variable "create_subnet_group" {
  description = "Create a subnet group"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs for the subnet group"
  type        = list(string)
  default     = []
}

variable "publicly_accessible" {
  description = "Whether the cluster is publicly accessible"
  type        = bool
  default     = false
}

variable "elastic_ip" {
  description = "Elastic IP for the cluster (if publicly accessible)"
  type        = string
  default     = null
}

variable "enhanced_vpc_routing" {
  description = "Enable enhanced VPC routing"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Availability zone for single-node clusters"
  type        = string
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
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - PARAMETER GROUP
# ------------------------------------------------------------------------------

variable "cluster_parameter_group_name" {
  description = "Name of the cluster parameter group"
  type        = string
  default     = null
}

variable "create_parameter_group" {
  description = "Create a parameter group"
  type        = bool
  default     = false
}

variable "parameter_group_family" {
  description = "Parameter group family (e.g., redshift-1.0)"
  type        = string
  default     = "redshift-1.0"
}

variable "parameters" {
  description = "Map of parameters for the parameter group"
  type = map(object({
    value = string
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SNAPSHOTS
# ------------------------------------------------------------------------------

variable "automated_snapshot_retention_period" {
  description = "Number of days to retain automated snapshots (0 to disable)"
  type        = number
  default     = 1
}

variable "snapshot_identifier" {
  description = "Snapshot identifier to restore from"
  type        = string
  default     = null
}

variable "snapshot_cluster_identifier" {
  description = "Cluster identifier of the snapshot to restore"
  type        = string
  default     = null
}

variable "final_snapshot_identifier" {
  description = "Identifier for the final snapshot (null to skip)"
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "snapshot_copy" {
  description = "Snapshot copy configuration for cross-region replication"
  type = object({
    destination_region = string
    retention_period   = optional(number, 7)
    grant_name         = optional(string)
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - MAINTENANCE
# ------------------------------------------------------------------------------

variable "preferred_maintenance_window" {
  description = "Preferred maintenance window (e.g., sun:05:00-sun:06:00)"
  type        = string
  default     = null
}

variable "allow_version_upgrade" {
  description = "Allow automatic major version upgrades"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply changes immediately instead of during maintenance window"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - IAM ROLES
# ------------------------------------------------------------------------------

variable "iam_roles" {
  description = "List of IAM role ARNs for the cluster"
  type        = list(string)
  default     = []
}

variable "default_iam_role_arn" {
  description = "Default IAM role ARN for the cluster"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LOGGING
# ------------------------------------------------------------------------------

variable "logging" {
  description = "Logging configuration"
  type = object({
    enable               = bool
    bucket_name          = optional(string)
    s3_key_prefix        = optional(string)
    log_destination_type = optional(string, "s3")
    log_exports          = optional(list(string), ["connectionlog", "userlog", "useractivitylog"])
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ADVANCED
# ------------------------------------------------------------------------------

variable "aqua_configuration_status" {
  description = "AQUA configuration status (enabled, disabled, auto)"
  type        = string
  default     = "auto"

  validation {
    condition     = contains(["enabled", "disabled", "auto"], var.aqua_configuration_status)
    error_message = "AQUA configuration status must be enabled, disabled, or auto."
  }
}

variable "availability_zone_relocation_enabled" {
  description = "Enable AZ relocation"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Enable multi-AZ deployment (RA3 node types only)"
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
