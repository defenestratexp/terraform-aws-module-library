# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the Auto Scaling Group"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.name)) && length(var.name) >= 3 && length(var.name) <= 255
    error_message = "Name must be 3-255 characters, alphanumeric and hyphens, cannot start/end with hyphen."
  }
}

variable "launch_template_id" {
  description = "ID of the launch template to use"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to launch instances in"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID is required."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CAPACITY
# ------------------------------------------------------------------------------

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances (defaults to min_size)"
  type        = number
  default     = null
}

variable "launch_template_version" {
  description = "Version of the launch template ($Latest, $Default, or version number)"
  type        = string
  default     = "$Latest"
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - HEALTH & LIFECYCLE
# ------------------------------------------------------------------------------

variable "health_check_type" {
  description = "Type of health check (EC2, ELB)"
  type        = string
  default     = "EC2"

  validation {
    condition     = contains(["EC2", "ELB"], var.health_check_type)
    error_message = "Health check type must be EC2 or ELB."
  }
}

variable "health_check_grace_period" {
  description = "Time in seconds after instance launch before health check starts"
  type        = number
  default     = 300
}

variable "default_cooldown" {
  description = "Time in seconds between scaling activities"
  type        = number
  default     = 300
}

variable "wait_for_capacity_timeout" {
  description = "Maximum time to wait for capacity (e.g., 10m)"
  type        = string
  default     = "10m"
}

variable "protect_from_scale_in" {
  description = "Protect instances from scale in by default"
  type        = bool
  default     = false
}

variable "termination_policies" {
  description = "List of termination policies (OldestInstance, NewestInstance, OldestLaunchTemplate, etc.)"
  type        = list(string)
  default     = ["Default"]
}

variable "suspended_processes" {
  description = "List of processes to suspend (Launch, Terminate, HealthCheck, etc.)"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LOAD BALANCER
# ------------------------------------------------------------------------------

variable "target_group_arns" {
  description = "List of target group ARNs to attach"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - INSTANCE REFRESH
# ------------------------------------------------------------------------------

variable "instance_refresh_enabled" {
  description = "Enable instance refresh for rolling updates"
  type        = bool
  default     = false
}

variable "instance_refresh_strategy" {
  description = "Instance refresh strategy (Rolling)"
  type        = string
  default     = "Rolling"
}

variable "instance_refresh_min_healthy_percentage" {
  description = "Minimum healthy percentage during instance refresh"
  type        = number
  default     = 50
}

variable "instance_refresh_instance_warmup" {
  description = "Warmup time in seconds for new instances during refresh"
  type        = number
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SCALING POLICIES
# ------------------------------------------------------------------------------

variable "enable_target_tracking_scaling" {
  description = "Enable target tracking scaling policy"
  type        = bool
  default     = false
}

variable "target_tracking_cpu_target" {
  description = "Target CPU utilization percentage for scaling"
  type        = number
  default     = 50
}

variable "target_tracking_disable_scale_in" {
  description = "Disable scale-in for target tracking policy"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags to apply to the ASG"
  type        = map(string)
  default     = {}
}

variable "propagate_tags_at_launch" {
  description = "Tags to propagate to instances at launch"
  type        = map(string)
  default     = {}
}
