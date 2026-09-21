# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name for the VPN Gateway"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to attach the VPN Gateway to"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - VPN GATEWAY SETTINGS
# ------------------------------------------------------------------------------

variable "amazon_side_asn" {
  description = "ASN for the Amazon side of the gateway (default uses Amazon's pool)"
  type        = number
  default     = null
}

variable "availability_zone" {
  description = "Availability Zone for the gateway (for single-AZ deployments)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CUSTOMER GATEWAY
# ------------------------------------------------------------------------------

variable "create_customer_gateway" {
  description = "Whether to create a Customer Gateway"
  type        = bool
  default     = false
}

variable "customer_gateway_bgp_asn" {
  description = "BGP ASN for the customer gateway"
  type        = number
  default     = 65000
}

variable "customer_gateway_ip_address" {
  description = "Public IP address of the customer gateway device"
  type        = string
  default     = ""
}

variable "customer_gateway_type" {
  description = "Type of customer gateway (ipsec.1)"
  type        = string
  default     = "ipsec.1"
}

variable "customer_gateway_certificate_arn" {
  description = "ARN of certificate for customer gateway device"
  type        = string
  default     = null
}

variable "customer_gateway_device_name" {
  description = "Name for the customer gateway device"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - VPN CONNECTION
# ------------------------------------------------------------------------------

variable "create_vpn_connection" {
  description = "Whether to create a VPN connection"
  type        = bool
  default     = false
}

variable "vpn_connection_type" {
  description = "Type of VPN connection (ipsec.1)"
  type        = string
  default     = "ipsec.1"
}

variable "vpn_connection_static_routes_only" {
  description = "Whether to use static routes only (no BGP)"
  type        = bool
  default     = false
}

variable "vpn_connection_static_routes" {
  description = "List of static route destination CIDR blocks"
  type        = list(string)
  default     = []
}

variable "vpn_connection_local_ipv4_network_cidr" {
  description = "IPv4 CIDR on the customer gateway side"
  type        = string
  default     = "0.0.0.0/0"
}

variable "vpn_connection_remote_ipv4_network_cidr" {
  description = "IPv4 CIDR on the AWS side"
  type        = string
  default     = "0.0.0.0/0"
}

variable "vpn_connection_tunnel1_inside_cidr" {
  description = "Inside IP CIDR for tunnel 1 (/30 from 169.254.0.0/16)"
  type        = string
  default     = null
}

variable "vpn_connection_tunnel2_inside_cidr" {
  description = "Inside IP CIDR for tunnel 2 (/30 from 169.254.0.0/16)"
  type        = string
  default     = null
}

variable "vpn_connection_tunnel1_preshared_key" {
  description = "Pre-shared key for tunnel 1 (auto-generated if not specified)"
  type        = string
  default     = null
  sensitive   = true
}

variable "vpn_connection_tunnel2_preshared_key" {
  description = "Pre-shared key for tunnel 2 (auto-generated if not specified)"
  type        = string
  default     = null
  sensitive   = true
}

variable "vpn_connection_tunnel1_dpd_timeout_action" {
  description = "DPD timeout action for tunnel 1 (clear, none, restart)"
  type        = string
  default     = "clear"
}

variable "vpn_connection_tunnel2_dpd_timeout_action" {
  description = "DPD timeout action for tunnel 2 (clear, none, restart)"
  type        = string
  default     = "clear"
}

variable "vpn_connection_tunnel1_ike_versions" {
  description = "IKE versions for tunnel 1"
  type        = list(string)
  default     = ["ikev1", "ikev2"]
}

variable "vpn_connection_tunnel2_ike_versions" {
  description = "IKE versions for tunnel 2"
  type        = list(string)
  default     = ["ikev1", "ikev2"]
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ROUTE PROPAGATION
# ------------------------------------------------------------------------------

variable "route_table_ids" {
  description = "Route table IDs for VPN route propagation"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CLOUDWATCH LOGGING
# ------------------------------------------------------------------------------

variable "enable_tunnel_logging" {
  description = "Enable CloudWatch logging for VPN tunnels"
  type        = bool
  default     = false
}

variable "tunnel_log_group_name" {
  description = "CloudWatch log group name for tunnel logs"
  type        = string
  default     = ""
}

variable "tunnel_log_retention_days" {
  description = "Retention days for tunnel logs"
  type        = number
  default     = 30
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
