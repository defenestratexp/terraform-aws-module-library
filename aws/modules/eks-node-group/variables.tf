# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the node group"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the node group"
  type        = list(string)
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SCALING
# ------------------------------------------------------------------------------

variable "desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 5
}

variable "max_unavailable" {
  description = "Maximum unavailable nodes during update"
  type        = number
  default     = 1
}

variable "max_unavailable_percentage" {
  description = "Maximum unavailable percentage during update (overrides max_unavailable)"
  type        = number
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - INSTANCE CONFIGURATION
# ------------------------------------------------------------------------------

variable "instance_types" {
  description = "Instance types for the node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "capacity_type" {
  description = "Capacity type (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.capacity_type)
    error_message = "capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "disk_size" {
  description = "Disk size in GiB for nodes"
  type        = number
  default     = 20
}

variable "ami_type" {
  description = "AMI type (AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, BOTTLEROCKET_x86_64, BOTTLEROCKET_ARM_64)"
  type        = string
  default     = "AL2_x86_64"
}

variable "release_version" {
  description = "AMI release version (defaults to latest)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - IAM
# ------------------------------------------------------------------------------

variable "node_role_arn" {
  description = "ARN of the node IAM role (created if not provided)"
  type        = string
  default     = null
}

variable "create_node_role" {
  description = "Create the node IAM role"
  type        = bool
  default     = true
}

variable "node_role_policies" {
  description = "Additional policy ARNs to attach to node role"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LAUNCH TEMPLATE
# ------------------------------------------------------------------------------

variable "use_custom_launch_template" {
  description = "Use a custom launch template"
  type        = bool
  default     = false
}

variable "launch_template_id" {
  description = "ID of custom launch template"
  type        = string
  default     = null
}

variable "launch_template_version" {
  description = "Version of custom launch template"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - REMOTE ACCESS
# ------------------------------------------------------------------------------

variable "remote_access" {
  description = "Remote access configuration"
  type = object({
    ec2_ssh_key               = optional(string)
    source_security_group_ids = optional(list(string), [])
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAINTS AND LABELS
# ------------------------------------------------------------------------------

variable "labels" {
  description = "Kubernetes labels to apply to nodes"
  type        = map(string)
  default     = {}
}

variable "taints" {
  description = "Kubernetes taints to apply to nodes"
  type = list(object({
    key    = string
    value  = optional(string)
    effect = string
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
