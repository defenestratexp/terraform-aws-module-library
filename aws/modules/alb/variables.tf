# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the Application Load Balancer"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.name)) && length(var.name) >= 3 && length(var.name) <= 32
    error_message = "Name must be 3-32 characters, alphanumeric and hyphens, cannot start/end with hyphen."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB (must be in at least 2 AZs)"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnet IDs in different AZs are required."
  }
}

variable "security_group_ids" {
  description = "List of security group IDs for the ALB"
  type        = list(string)

  validation {
    condition     = length(var.security_group_ids) > 0
    error_message = "At least one security group ID is required."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LOAD BALANCER
# ------------------------------------------------------------------------------

variable "internal" {
  description = "If true, creates an internal load balancer"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Enable HTTP/2"
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "Idle timeout in seconds"
  type        = number
  default     = 60
}

variable "drop_invalid_header_fields" {
  description = "Drop invalid HTTP header fields"
  type        = bool
  default     = true
}

variable "preserve_host_header" {
  description = "Preserve the Host header"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - ACCESS LOGS
# ------------------------------------------------------------------------------

variable "enable_access_logs" {
  description = "Enable access logs"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket for access logs"
  type        = string
  default     = ""
}

variable "access_logs_prefix" {
  description = "S3 prefix for access logs"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LISTENERS
# ------------------------------------------------------------------------------

variable "create_http_listener" {
  description = "Create HTTP listener on port 80"
  type        = bool
  default     = true
}

variable "http_listener_action" {
  description = "Default action for HTTP listener (forward, redirect)"
  type        = string
  default     = "redirect"

  validation {
    condition     = contains(["forward", "redirect"], var.http_listener_action)
    error_message = "HTTP listener action must be forward or redirect."
  }
}

variable "http_listener_target_group_arn" {
  description = "Target group ARN for HTTP listener (when action is forward)"
  type        = string
  default     = ""
}

variable "create_https_listener" {
  description = "Create HTTPS listener on port 443"
  type        = bool
  default     = false
}

variable "https_listener_certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
  default     = ""
}

variable "https_listener_target_group_arn" {
  description = "Target group ARN for HTTPS listener"
  type        = string
  default     = ""
}

variable "https_listener_ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "additional_certificates" {
  description = "List of additional ACM certificate ARNs for HTTPS listener"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
