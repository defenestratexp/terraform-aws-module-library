# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the launch template"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]*[a-zA-Z0-9]$", var.name)) && length(var.name) >= 3 && length(var.name) <= 128
    error_message = "Name must be 3-128 characters, alphanumeric, hyphens and underscores, cannot start/end with hyphen or underscore."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - AMI
# ------------------------------------------------------------------------------

variable "ami_id" {
  description = "ID of the AMI to use. If not provided, uses latest Amazon Linux 2023"
  type        = string
  default     = ""
}

variable "ami_filter_name" {
  description = "Name filter for AMI lookup (used if ami_id not provided)"
  type        = string
  default     = "al2023-ami-*-x86_64"
}

variable "ami_owners" {
  description = "List of AMI owners for lookup (used if ami_id not provided)"
  type        = list(string)
  default     = ["amazon"]
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - INSTANCE
# ------------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair to use"
  type        = string
  default     = ""
}

variable "security_group_ids" {
  description = "List of security group IDs to attach"
  type        = list(string)
  default     = []
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile to attach"
  type        = string
  default     = ""
}

variable "iam_instance_profile_arn" {
  description = "ARN of the IAM instance profile to attach (takes precedence over name)"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "User data script (will be base64 encoded)"
  type        = string
  default     = ""
}

variable "user_data_base64" {
  description = "Base64-encoded user data (takes precedence over user_data)"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - STORAGE
# ------------------------------------------------------------------------------

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of the root EBS volume (gp3, gp2, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Encrypt the root EBS volume"
  type        = bool
  default     = true
}

variable "root_volume_kms_key_id" {
  description = "KMS key ID for root volume encryption"
  type        = string
  default     = ""
}

variable "root_volume_iops" {
  description = "IOPS for root volume (gp3, io1, io2)"
  type        = number
  default     = null
}

variable "root_volume_throughput" {
  description = "Throughput for root volume in MB/s (gp3 only)"
  type        = number
  default     = null
}

variable "delete_on_termination" {
  description = "Delete root volume when instance is terminated"
  type        = bool
  default     = true
}

variable "additional_block_devices" {
  description = "Additional block device mappings"
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = optional(string, "gp3")
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string, "")
    iops                  = optional(number, null)
    throughput            = optional(number, null)
    delete_on_termination = optional(bool, true)
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - MONITORING & METADATA
# ------------------------------------------------------------------------------

variable "monitoring_enabled" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "metadata_http_tokens" {
  description = "Require IMDSv2 tokens (required, optional)"
  type        = string
  default     = "required"
}

variable "metadata_http_endpoint" {
  description = "Enable instance metadata endpoint (enabled, disabled)"
  type        = string
  default     = "enabled"
}

variable "metadata_http_put_response_hop_limit" {
  description = "HTTP PUT response hop limit for IMDS"
  type        = number
  default     = 1
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LIFECYCLE
# ------------------------------------------------------------------------------

variable "update_default_version" {
  description = "Update default version on each change"
  type        = bool
  default     = true
}

variable "description" {
  description = "Description of the launch template"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "instance_tags" {
  description = "Tags to apply to instances launched from this template"
  type        = map(string)
  default     = {}
}

variable "volume_tags" {
  description = "Tags to apply to volumes created from this template"
  type        = map(string)
  default     = {}
}
