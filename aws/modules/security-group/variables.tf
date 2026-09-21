# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the security group"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.name)) && length(var.name) >= 3 && length(var.name) <= 64
    error_message = "Name must be 3-64 characters, lowercase alphanumeric and hyphens, cannot start/end with hyphen."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where the security group will be created"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ------------------------------------------------------------------------------

variable "description" {
  description = "Description of the security group"
  type        = string
  default     = "Managed by Terraform"
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), [])
    ipv6_cidr_blocks         = optional(list(string), [])
    source_security_group_id = optional(string, null)
    self                     = optional(bool, false)
    description              = optional(string, "")
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules. Defaults to allow all outbound."
  type = list(object({
    from_port                     = number
    to_port                       = number
    protocol                      = string
    cidr_blocks                   = optional(list(string), [])
    ipv6_cidr_blocks              = optional(list(string), [])
    destination_security_group_id = optional(string, null)
    self                          = optional(bool, false)
    description                   = optional(string, "")
  }))
  default = []
}

variable "allow_all_egress" {
  description = "Add a default rule allowing all outbound traffic"
  type        = bool
  default     = true
}

variable "revoke_rules_on_delete" {
  description = "Revoke all rules before deleting the security group"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to the security group"
  type        = map(string)
  default     = {}
}
