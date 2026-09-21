# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the EC2 instance"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.name)) && length(var.name) >= 3 && length(var.name) <= 64
    error_message = "Name must be 3-64 characters, alphanumeric and hyphens, cannot start/end with hyphen."
  }
}

variable "subnet_id" {
  description = "ID of the subnet to launch the instance in"
  type        = string
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

variable "iam_instance_profile" {
  description = "Name of the IAM instance profile to attach"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "User data script to run on instance launch"
  type        = string
  default     = ""
}

variable "user_data_base64" {
  description = "Base64-encoded user data (takes precedence over user_data)"
  type        = string
  default     = ""
}

variable "user_data_replace_on_change" {
  description = "Recreate instance when user data changes"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - NETWORKING
# ------------------------------------------------------------------------------

variable "associate_public_ip_address" {
  description = "Associate a public IP address with the instance"
  type        = bool
  default     = null
}

variable "private_ip" {
  description = "Private IP address to assign (must be within subnet CIDR)"
  type        = string
  default     = null
}

variable "source_dest_check" {
  description = "Enable source/destination check (disable for NAT instances)"
  type        = bool
  default     = true
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
  description = "Type of the root EBS volume (gp3, gp2, io1, io2, st1, sc1)"
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Encrypt the root EBS volume"
  type        = bool
  default     = true
}

variable "root_volume_kms_key_id" {
  description = "KMS key ID for root volume encryption (uses AWS managed key if empty)"
  type        = string
  default     = ""
}

variable "delete_on_termination" {
  description = "Delete root volume when instance is terminated"
  type        = bool
  default     = true
}

variable "additional_ebs_volumes" {
  description = "List of additional EBS volumes to attach"
  type = list(object({
    device_name = string
    volume_size = number
    volume_type = optional(string, "gp3")
    encrypted   = optional(bool, true)
    kms_key_id  = optional(string, "")
    iops        = optional(number, null)
    throughput  = optional(number, null)
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - MONITORING & METADATA
# ------------------------------------------------------------------------------

variable "monitoring" {
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

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LIFECYCLE
# ------------------------------------------------------------------------------

variable "disable_api_termination" {
  description = "Enable termination protection"
  type        = bool
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior (stop, terminate)"
  type        = string
  default     = "stop"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
