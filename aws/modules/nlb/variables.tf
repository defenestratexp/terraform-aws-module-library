# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the Network Load Balancer"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.name)) && length(var.name) >= 3 && length(var.name) <= 32
    error_message = "Name must be 3-32 characters, alphanumeric and hyphens, cannot start/end with hyphen."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for the NLB"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 1
    error_message = "At least 1 subnet ID is required."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LOAD BALANCER
# ------------------------------------------------------------------------------

variable "internal" {
  description = "If true, creates an internal load balancer"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

variable "enable_client_ip_preservation" {
  description = "Preserve client IP address"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ELASTIC IPS
# ------------------------------------------------------------------------------

variable "use_elastic_ips" {
  description = "Use Elastic IPs for the NLB"
  type        = bool
  default     = false
}

variable "elastic_ip_allocation_ids" {
  description = "List of Elastic IP allocation IDs (one per subnet)"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LISTENERS
# ------------------------------------------------------------------------------

variable "listeners" {
  description = "List of listeners to create"
  type = list(object({
    port             = number
    protocol         = string
    target_group_arn = string
    certificate_arn  = optional(string, "")
    ssl_policy       = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")
    alpn_policy      = optional(string, null)
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ACCESS LOGS
# ------------------------------------------------------------------------------

variable "enable_access_logs" {
  description = "Enable access logs"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket for access logs"
  type        = string
  default     = ""
}

variable "access_logs_prefix" {
  description = "S3 prefix for access logs"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
