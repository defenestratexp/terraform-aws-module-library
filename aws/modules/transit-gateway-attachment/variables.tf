# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name for the Transit Gateway attachment"
  type        = string
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to attach"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs in the VPC for the attachment (one per AZ recommended)"
  type        = list(string)
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ATTACHMENT SETTINGS
# ------------------------------------------------------------------------------

variable "dns_support" {
  description = "Whether DNS support is enabled"
  type        = string
  default     = "enable"

  validation {
    condition     = contains(["enable", "disable"], var.dns_support)
    error_message = "dns_support must be 'enable' or 'disable'."
  }
}

variable "ipv6_support" {
  description = "Whether IPv6 support is enabled"
  type        = string
  default     = "disable"

  validation {
    condition     = contains(["enable", "disable"], var.ipv6_support)
    error_message = "ipv6_support must be 'enable' or 'disable'."
  }
}

variable "appliance_mode_support" {
  description = "Whether appliance mode is enabled (for stateful network appliances)"
  type        = string
  default     = "disable"

  validation {
    condition     = contains(["enable", "disable"], var.appliance_mode_support)
    error_message = "appliance_mode_support must be 'enable' or 'disable'."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ROUTE TABLE ASSOCIATION
# ------------------------------------------------------------------------------

variable "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway route table to associate with"
  type        = string
  default     = ""
}

variable "transit_gateway_route_table_propagation_ids" {
  description = "List of Transit Gateway route table IDs to propagate routes to"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - VPC ROUTES
# ------------------------------------------------------------------------------

variable "vpc_route_table_ids" {
  description = "VPC route table IDs to add routes to the Transit Gateway"
  type        = list(string)
  default     = []
}

variable "destination_cidr_blocks" {
  description = "Destination CIDR blocks for routes via the Transit Gateway"
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
