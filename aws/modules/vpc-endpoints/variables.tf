# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "vpc_id" {
  description = "VPC ID for the endpoints"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - GATEWAY ENDPOINTS
# ------------------------------------------------------------------------------

variable "gateway_endpoints" {
  description = "Map of gateway endpoint configurations (S3, DynamoDB)"
  type = map(object({
    service         = string
    route_table_ids = list(string)
    policy          = optional(string, null)
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - INTERFACE ENDPOINTS
# ------------------------------------------------------------------------------

variable "interface_endpoints" {
  description = "Map of interface endpoint configurations"
  type = map(object({
    service             = string
    subnet_ids          = list(string)
    security_group_ids  = optional(list(string), [])
    private_dns_enabled = optional(bool, true)
    policy              = optional(string, null)
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - COMMON INTERFACE ENDPOINT SETTINGS
# ------------------------------------------------------------------------------

variable "default_subnet_ids" {
  description = "Default subnet IDs for interface endpoints"
  type        = list(string)
  default     = []
}

variable "default_security_group_ids" {
  description = "Default security group IDs for interface endpoints"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
