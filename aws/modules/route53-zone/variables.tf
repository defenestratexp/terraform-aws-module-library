# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Domain name for the hosted zone"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ZONE TYPE
# ------------------------------------------------------------------------------

variable "is_private" {
  description = "Create a private hosted zone"
  type        = bool
  default     = false
}

variable "vpc_associations" {
  description = "List of VPCs to associate with private hosted zone"
  type = list(object({
    vpc_id     = string
    vpc_region = optional(string, null)
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DELEGATION SET
# ------------------------------------------------------------------------------

variable "delegation_set_id" {
  description = "ID of a reusable delegation set"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DNSSEC
# ------------------------------------------------------------------------------

variable "enable_dnssec" {
  description = "Enable DNSSEC signing for the zone"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - QUERY LOGGING
# ------------------------------------------------------------------------------

variable "enable_query_logging" {
  description = "Enable query logging to CloudWatch Logs"
  type        = bool
  default     = false
}

variable "query_log_group_arn" {
  description = "ARN of CloudWatch Logs group for query logging"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - COMMENT
# ------------------------------------------------------------------------------

variable "comment" {
  description = "Comment for the hosted zone"
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
