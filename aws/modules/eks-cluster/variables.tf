# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS cluster (at least 2 in different AZs)"
  type        = list(string)
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CLUSTER SETTINGS
# ------------------------------------------------------------------------------

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster"
  type        = string
  default     = null
}

variable "enabled_cluster_log_types" {
  description = "List of control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_days" {
  description = "Retention days for cluster logs"
  type        = number
  default     = 30
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - NETWORK CONFIGURATION
# ------------------------------------------------------------------------------

variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to access public API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "security_group_ids" {
  description = "Additional security group IDs for the cluster"
  type        = list(string)
  default     = []
}

variable "service_ipv4_cidr" {
  description = "CIDR block for Kubernetes service IPs"
  type        = string
  default     = null
}

variable "ip_family" {
  description = "IP family for the cluster (ipv4 or ipv6)"
  type        = string
  default     = "ipv4"
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - IAM
# ------------------------------------------------------------------------------

variable "cluster_role_arn" {
  description = "ARN of the cluster IAM role (created if not provided)"
  type        = string
  default     = null
}

variable "create_cluster_role" {
  description = "Create the cluster IAM role"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ENCRYPTION
# ------------------------------------------------------------------------------

variable "encryption_config" {
  description = "Encryption configuration for secrets"
  type = object({
    provider_key_arn = string
    resources        = optional(list(string), ["secrets"])
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ADD-ONS
# ------------------------------------------------------------------------------

variable "cluster_addons" {
  description = "Map of cluster add-ons to install"
  type = map(object({
    addon_version               = optional(string)
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    service_account_role_arn    = optional(string)
    configuration_values        = optional(string)
  }))
  default = {}
}

variable "enable_default_addons" {
  description = "Enable default add-ons (vpc-cni, coredns, kube-proxy)"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ACCESS CONFIG
# ------------------------------------------------------------------------------

variable "authentication_mode" {
  description = "Authentication mode (API, API_AND_CONFIG_MAP, CONFIG_MAP)"
  type        = string
  default     = "API_AND_CONFIG_MAP"
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Grant cluster creator admin access"
  type        = bool
  default     = true
}

variable "access_entries" {
  description = "Map of access entries for IAM principals"
  type = map(object({
    principal_arn     = string
    kubernetes_groups = optional(list(string), [])
    type              = optional(string, "STANDARD")
    policy_associations = optional(map(object({
      policy_arn = string
      access_scope = object({
        type       = string
        namespaces = optional(list(string), [])
      })
    })), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - OIDC PROVIDER
# ------------------------------------------------------------------------------

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts (IRSA)"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
