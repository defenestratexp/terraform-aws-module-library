# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name for the VPC peering connection"
  type        = string
}

variable "requester_vpc_id" {
  description = "ID of the requester VPC"
  type        = string
}

variable "accepter_vpc_id" {
  description = "ID of the accepter VPC"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CROSS-ACCOUNT/REGION
# ------------------------------------------------------------------------------

variable "peer_owner_id" {
  description = "AWS account ID of the accepter VPC owner (for cross-account peering)"
  type        = string
  default     = ""
}

variable "peer_region" {
  description = "Region of the accepter VPC (for cross-region peering)"
  type        = string
  default     = ""
}

variable "auto_accept" {
  description = "Auto-accept the peering connection (only works for same-account, same-region)"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - PEERING OPTIONS
# ------------------------------------------------------------------------------

variable "allow_remote_vpc_dns_resolution" {
  description = "Allow DNS resolution from the remote VPC"
  type        = bool
  default     = true
}

variable "allow_classic_link_to_remote_vpc" {
  description = "Allow ClassicLink connection to the remote VPC"
  type        = bool
  default     = false
}

variable "allow_vpc_to_remote_classic_link" {
  description = "Allow connection to the remote VPC's ClassicLink"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ROUTING
# ------------------------------------------------------------------------------

variable "requester_route_table_ids" {
  description = "Route table IDs in requester VPC for routes to accepter"
  type        = list(string)
  default     = []
}

variable "accepter_route_table_ids" {
  description = "Route table IDs in accepter VPC for routes to requester"
  type        = list(string)
  default     = []
}

variable "requester_cidr_block" {
  description = "CIDR block of the requester VPC (for route creation)"
  type        = string
  default     = ""
}

variable "accepter_cidr_block" {
  description = "CIDR block of the accepter VPC (for route creation)"
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
