# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "cluster_id" {
  description = "ID of the Memcached cluster"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.cluster_id)) && length(var.cluster_id) <= 50
    error_message = "Cluster ID must start with a letter, contain only lowercase letters, numbers, and hyphens, and be max 50 characters."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENGINE
# ------------------------------------------------------------------------------

variable "engine_version" {
  description = "Memcached engine version"
  type        = string
  default     = "1.6.22"
}

variable "node_type" {
  description = "Node type (e.g., cache.t3.micro, cache.r6g.large)"
  type        = string
  default     = "cache.t3.micro"
}

variable "port" {
  description = "Port number"
  type        = number
  default     = 11211
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CLUSTER
# ------------------------------------------------------------------------------

variable "num_cache_nodes" {
  description = "Number of cache nodes in the cluster"
  type        = number
  default     = 1

  validation {
    condition     = var.num_cache_nodes >= 1 && var.num_cache_nodes <= 40
    error_message = "Number of cache nodes must be between 1 and 40."
  }
}

variable "az_mode" {
  description = "AZ mode (single-az or cross-az)"
  type        = string
  default     = "single-az"

  validation {
    condition     = contains(["single-az", "cross-az"], var.az_mode)
    error_message = "AZ mode must be single-az or cross-az."
  }
}

variable "preferred_availability_zones" {
  description = "List of preferred availability zones for cache nodes"
  type        = list(string)
  default     = []
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
# OPTIONAL VARIABLES - PARAMETERS
# ------------------------------------------------------------------------------

variable "parameter_group_name" {
  description = "Name of an existing parameter group"
  type        = string
  default     = ""
}

variable "parameter_group_family" {
  description = "Parameter group family (e.g., memcached1.6)"
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
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
