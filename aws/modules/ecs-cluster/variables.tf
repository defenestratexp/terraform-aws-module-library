# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the ECS cluster"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CONTAINER INSIGHTS
# ------------------------------------------------------------------------------

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - CAPACITY PROVIDERS
# ------------------------------------------------------------------------------

variable "enable_fargate" {
  description = "Enable Fargate capacity provider"
  type        = bool
  default     = true
}

variable "enable_fargate_spot" {
  description = "Enable Fargate Spot capacity provider"
  type        = bool
  default     = false
}

variable "default_capacity_provider" {
  description = "Default capacity provider (FARGATE, FARGATE_SPOT, or custom ASG provider name)"
  type        = string
  default     = "FARGATE"
}

variable "capacity_provider_weights" {
  description = "Weights for capacity provider strategy"
  type = object({
    fargate      = optional(number, 1)
    fargate_spot = optional(number, 0)
  })
  default = {
    fargate      = 1
    fargate_spot = 0
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - EC2 CAPACITY PROVIDER (AUTO SCALING GROUP)
# ------------------------------------------------------------------------------

variable "autoscaling_capacity_providers" {
  description = "Map of Auto Scaling Group capacity providers"
  type = map(object({
    auto_scaling_group_arn         = string
    managed_termination_protection = optional(string, "DISABLED")
    managed_scaling = optional(object({
      maximum_scaling_step_size = optional(number, 1000)
      minimum_scaling_step_size = optional(number, 1)
      status                    = optional(string, "ENABLED")
      target_capacity           = optional(number, 100)
      instance_warmup_period    = optional(number, 300)
    }), {})
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - SERVICE CONNECT
# ------------------------------------------------------------------------------

variable "service_connect_defaults" {
  description = "Service Connect defaults for the cluster"
  type = object({
    namespace = string
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - EXECUTE COMMAND
# ------------------------------------------------------------------------------

variable "execute_command_configuration" {
  description = "Configuration for ECS Exec"
  type = object({
    kms_key_id = optional(string)
    logging    = optional(string, "DEFAULT")
    log_configuration = optional(object({
      cloud_watch_encryption_enabled = optional(bool, true)
      cloud_watch_log_group_name     = optional(string)
      s3_bucket_name                 = optional(string)
      s3_bucket_encryption_enabled   = optional(bool, true)
      s3_key_prefix                  = optional(string)
    }))
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LOGGING
# ------------------------------------------------------------------------------

variable "create_cloudwatch_log_group" {
  description = "Create CloudWatch log group for execute command logging"
  type        = bool
  default     = false
}

variable "cloudwatch_log_group_retention" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 30
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "KMS key ID for CloudWatch log group encryption"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TAGS
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
