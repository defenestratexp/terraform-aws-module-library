# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the target group"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.name)) && length(var.name) >= 3 && length(var.name) <= 32
    error_message = "Name must be 3-32 characters, alphanumeric and hyphens, cannot start/end with hyphen."
  }
}

variable "vpc_id" {
  description = "ID of the VPC for the target group"
  type        = string
}

variable "port" {
  description = "Port on which targets receive traffic"
  type        = number
}

variable "protocol" {
  description = "Protocol for the target group (HTTP, HTTPS, TCP, UDP, TCP_UDP, TLS)"
  type        = string

  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP", "UDP", "TCP_UDP", "TLS"], var.protocol)
    error_message = "Protocol must be one of: HTTP, HTTPS, TCP, UDP, TCP_UDP, TLS."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TARGET TYPE
# ------------------------------------------------------------------------------

variable "target_type" {
  description = "Type of target (instance, ip, lambda, alb)"
  type        = string
  default     = "instance"

  validation {
    condition     = contains(["instance", "ip", "lambda", "alb"], var.target_type)
    error_message = "Target type must be one of: instance, ip, lambda, alb."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - HEALTH CHECK
# ------------------------------------------------------------------------------

variable "health_check_enabled" {
  description = "Enable health checks"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check path (HTTP/HTTPS only)"
  type        = string
  default     = "/"
}

variable "health_check_port" {
  description = "Port for health check (traffic-port or specific port)"
  type        = string
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "Protocol for health check (defaults to target group protocol)"
  type        = string
  default     = ""
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks"
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks"
  type        = number
  default     = 3
}

variable "health_check_matcher" {
  description = "HTTP status codes to consider healthy (HTTP/HTTPS only)"
  type        = string
  default     = "200-299"
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - STICKINESS
# ------------------------------------------------------------------------------

variable "stickiness_enabled" {
  description = "Enable sticky sessions"
  type        = bool
  default     = false
}

variable "stickiness_type" {
  description = "Type of stickiness (lb_cookie, app_cookie, source_ip)"
  type        = string
  default     = "lb_cookie"
}

variable "stickiness_duration" {
  description = "Stickiness duration in seconds"
  type        = number
  default     = 86400
}

variable "stickiness_cookie_name" {
  description = "Cookie name for app_cookie stickiness"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - OTHER
# ------------------------------------------------------------------------------

variable "deregistration_delay" {
  description = "Time in seconds to wait before deregistering target"
  type        = number
  default     = 300
}

variable "slow_start" {
  description = "Slow start duration in seconds (0 to disable)"
  type        = number
  default     = 0
}

variable "load_balancing_algorithm_type" {
  description = "Load balancing algorithm (round_robin, least_outstanding_requests)"
  type        = string
  default     = "round_robin"
}

variable "lambda_multi_value_headers_enabled" {
  description = "Enable multi-value headers for Lambda targets"
  type        = bool
  default     = false
}

variable "proxy_protocol_v2" {
  description = "Enable proxy protocol v2 (NLB only)"
  type        = bool
  default     = false
}

variable "preserve_client_ip" {
  description = "Preserve client IP (NLB with IP target type)"
  type        = bool
  default     = true
}

variable "connection_termination" {
  description = "Terminate connections at deregistration (NLB only)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to the target group"
  type        = map(string)
  default     = {}
}
