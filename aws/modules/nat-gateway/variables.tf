# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name prefix for all NAT Gateway resources"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.name)) && length(var.name) >= 3 && length(var.name) <= 32
    error_message = "Name must be 3-32 characters, lowercase alphanumeric and hyphens, cannot start/end with hyphen."
  }
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs where NAT Gateways will be created"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) > 0
    error_message = "At least one public subnet ID is required."
  }
}

variable "private_route_table_ids" {
  description = "List of private route table IDs to add NAT routes to"
  type        = list(string)

  validation {
    condition     = length(var.private_route_table_ids) > 0
    error_message = "At least one private route table ID is required."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ------------------------------------------------------------------------------

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway instead of one per AZ (cheaper but less resilient)"
  type        = bool
  default     = false
}

variable "reuse_existing_eips" {
  description = "Use existing Elastic IPs instead of creating new ones"
  type        = bool
  default     = false
}

variable "existing_eip_allocation_ids" {
  description = "List of existing Elastic IP allocation IDs to use (required if reuse_existing_eips is true)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
