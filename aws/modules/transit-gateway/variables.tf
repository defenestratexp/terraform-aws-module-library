# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the Transit Gateway"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TRANSIT GATEWAY SETTINGS
# ------------------------------------------------------------------------------

variable "description" {
  description = "Description of the Transit Gateway"
  type        = string
  default     = ""
}

variable "amazon_side_asn" {
  description = "Private ASN for the Amazon side of the Gateway (64512-65534 or 4200000000-4294967294)"
  type        = number
  default     = 64512
}

variable "auto_accept_shared_attachments" {
  description = "Whether attachments are automatically accepted"
  type        = string
  default     = "disable"

  validation {
    condition     = contains(["enable", "disable"], var.auto_accept_shared_attachments)
    error_message = "auto_accept_shared_attachments must be 'enable' or 'disable'."
  }
}

variable "default_route_table_association" {
  description = "Whether attachments are automatically associated with the default route table"
  type        = string
  default     = "enable"

  validation {
    condition     = contains(["enable", "disable"], var.default_route_table_association)
    error_message = "default_route_table_association must be 'enable' or 'disable'."
  }
}

variable "default_route_table_propagation" {
  description = "Whether attachments automatically propagate routes to the default route table"
  type        = string
  default     = "enable"

  validation {
    condition     = contains(["enable", "disable"], var.default_route_table_propagation)
    error_message = "default_route_table_propagation must be 'enable' or 'disable'."
  }
}

variable "dns_support" {
  description = "Whether DNS support is enabled"
  type        = string
  default     = "enable"

  validation {
    condition     = contains(["enable", "disable"], var.dns_support)
    error_message = "dns_support must be 'enable' or 'disable'."
  }
}

variable "multicast_support" {
  description = "Whether multicast support is enabled"
  type        = string
  default     = "disable"

  validation {
    condition     = contains(["enable", "disable"], var.multicast_support)
    error_message = "multicast_support must be 'enable' or 'disable'."
  }
}

variable "vpn_ecmp_support" {
  description = "Whether VPN Equal Cost Multi-Path (ECMP) is enabled"
  type        = string
  default     = "enable"

  validation {
    condition     = contains(["enable", "disable"], var.vpn_ecmp_support)
    error_message = "vpn_ecmp_support must be 'enable' or 'disable'."
  }
}

variable "transit_gateway_cidr_blocks" {
  description = "CIDR blocks for the Transit Gateway (for Connect attachments)"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ROUTE TABLES
# ------------------------------------------------------------------------------

variable "create_default_route_table" {
  description = "Whether to use the default route table (always created)"
  type        = bool
  default     = true
}

variable "route_tables" {
  description = "Map of route tables to create"
  type = map(object({
    name = optional(string)
    tags = optional(map(string), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - RESOURCE SHARING (RAM)
# ------------------------------------------------------------------------------

variable "share_transit_gateway" {
  description = "Whether to share the Transit Gateway via RAM"
  type        = bool
  default     = false
}

variable "ram_share_name" {
  description = "Name of the RAM resource share"
  type        = string
  default     = ""
}

variable "ram_principals" {
  description = "List of principals (account IDs, OU ARNs, or organization ARN) to share with"
  type        = list(string)
  default     = []
}

variable "ram_allow_external_principals" {
  description = "Whether to allow external principals in the RAM share"
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
