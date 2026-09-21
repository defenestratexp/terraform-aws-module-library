# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the ECS service"
  type        = string
}

variable "cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "task_definition_arn" {
  description = "ARN of the task definition"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SERVICE SETTINGS
# ------------------------------------------------------------------------------

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "launch_type" {
  description = "Launch type (FARGATE, EC2, or EXTERNAL)"
  type        = string
  default     = null
}

variable "platform_version" {
  description = "Platform version for Fargate (e.g., LATEST, 1.4.0)"
  type        = string
  default     = "LATEST"
}

variable "scheduling_strategy" {
  description = "Scheduling strategy (REPLICA or DAEMON)"
  type        = string
  default     = "REPLICA"
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for debugging"
  type        = bool
  default     = false
}

variable "force_new_deployment" {
  description = "Force a new deployment on apply"
  type        = bool
  default     = false
}

variable "wait_for_steady_state" {
  description = "Wait for service to reach steady state"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CAPACITY PROVIDER STRATEGY
# ------------------------------------------------------------------------------

variable "capacity_provider_strategy" {
  description = "Capacity provider strategy"
  type = list(object({
    capacity_provider = string
    weight            = optional(number, 1)
    base              = optional(number, 0)
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - NETWORK CONFIGURATION
# ------------------------------------------------------------------------------

variable "subnet_ids" {
  description = "Subnet IDs for awsvpc network mode"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security group IDs for awsvpc network mode"
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Assign public IP to tasks"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LOAD BALANCER
# ------------------------------------------------------------------------------

variable "load_balancers" {
  description = "Load balancer configurations"
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
  default = []
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to wait before checking health after task start"
  type        = number
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SERVICE DISCOVERY
# ------------------------------------------------------------------------------

variable "service_registries" {
  description = "Service discovery registries"
  type = list(object({
    registry_arn   = string
    port           = optional(number)
    container_name = optional(string)
    container_port = optional(number)
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SERVICE CONNECT
# ------------------------------------------------------------------------------

variable "service_connect_configuration" {
  description = "Service Connect configuration"
  type = object({
    enabled   = bool
    namespace = optional(string)
    service = optional(object({
      port_name      = string
      discovery_name = optional(string)
      client_alias = optional(object({
        port     = number
        dns_name = optional(string)
      }))
    }))
    log_configuration = optional(object({
      log_driver = string
      options    = optional(map(string))
    }))
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - DEPLOYMENT CONFIGURATION
# ------------------------------------------------------------------------------

variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percent during deployment"
  type        = number
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "Maximum percent during deployment"
  type        = number
  default     = 200
}

variable "deployment_circuit_breaker" {
  description = "Deployment circuit breaker configuration"
  type = object({
    enable   = bool
    rollback = bool
  })
  default = {
    enable   = true
    rollback = true
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - AUTO SCALING
# ------------------------------------------------------------------------------

variable "enable_autoscaling" {
  description = "Enable auto scaling"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 10
}

variable "autoscaling_policies" {
  description = "Auto scaling policies"
  type = map(object({
    policy_type = optional(string, "TargetTrackingScaling")
    target_tracking = optional(object({
      predefined_metric_type = string
      target_value           = number
      scale_in_cooldown      = optional(number, 300)
      scale_out_cooldown     = optional(number, 60)
    }))
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - PLACEMENT
# ------------------------------------------------------------------------------

variable "ordered_placement_strategy" {
  description = "Placement strategy for EC2 launch type"
  type = list(object({
    type  = string
    field = optional(string)
  }))
  default = []
}

variable "placement_constraints" {
  description = "Placement constraints for EC2 launch type"
  type = list(object({
    type       = string
    expression = optional(string)
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

variable "propagate_tags" {
  description = "Propagate tags to tasks (SERVICE or TASK_DEFINITION)"
  type        = string
  default     = "SERVICE"
}
