# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the EventBridge rule"
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - RULE CONFIGURATION
# ------------------------------------------------------------------------------

variable "description" {
  description = "Description of the rule"
  type        = string
  default     = ""
}

variable "event_bus_name" {
  description = "Name of the event bus (default is the default event bus)"
  type        = string
  default     = "default"
}

variable "schedule_expression" {
  description = "Schedule expression (e.g., rate(5 minutes), cron(0 12 * * ? *))"
  type        = string
  default     = null
}

variable "event_pattern" {
  description = "Event pattern JSON for matching events"
  type        = string
  default     = null
}

variable "is_enabled" {
  description = "Whether the rule is enabled"
  type        = bool
  default     = true
}

variable "state" {
  description = "State of the rule (ENABLED, DISABLED, ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TARGETS
# ------------------------------------------------------------------------------

variable "targets" {
  description = "Map of targets for the rule"
  type = map(object({
    arn        = string
    role_arn   = optional(string)
    input      = optional(string)
    input_path = optional(string)
    input_transformer = optional(object({
      input_paths    = optional(map(string))
      input_template = string
    }))
    retry_policy = optional(object({
      maximum_event_age_in_seconds = optional(number, 86400)
      maximum_retry_attempts       = optional(number, 185)
    }))
    dead_letter_config = optional(object({
      arn = string
    }))
    # For ECS targets
    ecs_target = optional(object({
      task_definition_arn     = string
      task_count              = optional(number, 1)
      launch_type             = optional(string)
      platform_version        = optional(string)
      group                   = optional(string)
      enable_execute_command  = optional(bool, false)
      enable_ecs_managed_tags = optional(bool, false)
      propagate_tags          = optional(string)
      network_configuration = optional(object({
        subnets          = list(string)
        security_groups  = optional(list(string))
        assign_public_ip = optional(bool, false)
      }))
      capacity_provider_strategy = optional(list(object({
        capacity_provider = string
        weight            = optional(number, 1)
        base              = optional(number, 0)
      })))
    }))
    # For Step Functions targets
    sqs_target = optional(object({
      message_group_id = optional(string)
    }))
    # For Kinesis targets
    kinesis_target = optional(object({
      partition_key_path = optional(string)
    }))
    # For HTTP targets (API destinations)
    http_target = optional(object({
      path_parameter_values   = optional(list(string))
      query_string_parameters = optional(map(string))
      header_parameters       = optional(map(string))
    }))
    # For Batch targets
    batch_target = optional(object({
      job_definition = string
      job_name       = string
      array_size     = optional(number)
      job_attempts   = optional(number)
    }))
  }))
  default = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - LAMBDA PERMISSIONS
# ------------------------------------------------------------------------------

variable "create_lambda_permissions" {
  description = "Create Lambda permissions for Lambda targets"
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
