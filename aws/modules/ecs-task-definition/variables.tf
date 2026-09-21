# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "family" {
  description = "Family name for the task definition (used for versioning)"
  type        = string
}

variable "container_definitions" {
  description = "Container definitions JSON or list of container definition objects"
  type        = any
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - TASK SETTINGS
# ------------------------------------------------------------------------------

variable "cpu" {
  description = "CPU units for the task (required for Fargate)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory (MB) for the task (required for Fargate)"
  type        = number
  default     = 512
}

variable "requires_compatibilities" {
  description = "Launch type compatibility (FARGATE, EC2)"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "network_mode" {
  description = "Network mode (awsvpc, bridge, host, none)"
  type        = string
  default     = "awsvpc"
}

variable "runtime_platform" {
  description = "Runtime platform configuration"
  type = object({
    operating_system_family = optional(string, "LINUX")
    cpu_architecture        = optional(string, "X86_64")
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - IAM ROLES
# ------------------------------------------------------------------------------

variable "task_role_arn" {
  description = "ARN of the task IAM role (for container permissions)"
  type        = string
  default     = null
}

variable "execution_role_arn" {
  description = "ARN of the execution IAM role (for ECS agent permissions)"
  type        = string
  default     = null
}

variable "create_task_role" {
  description = "Create a task IAM role"
  type        = bool
  default     = false
}

variable "create_execution_role" {
  description = "Create an execution IAM role"
  type        = bool
  default     = false
}

variable "task_role_policies" {
  description = "Map of policy ARNs to attach to the task role"
  type        = map(string)
  default     = {}
}

variable "task_role_inline_policies" {
  description = "Map of inline policies to attach to the task role"
  type        = map(string)
  default     = {}
}

variable "execution_role_policies" {
  description = "Additional policy ARNs for the execution role"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - VOLUMES
# ------------------------------------------------------------------------------

variable "volumes" {
  description = "List of volume configurations"
  type = list(object({
    name      = string
    host_path = optional(string)
    docker_volume_configuration = optional(object({
      scope         = optional(string)
      autoprovision = optional(bool)
      driver        = optional(string)
      driver_opts   = optional(map(string))
      labels        = optional(map(string))
    }))
    efs_volume_configuration = optional(object({
      file_system_id          = string
      root_directory          = optional(string)
      transit_encryption      = optional(string)
      transit_encryption_port = optional(number)
      authorization_config = optional(object({
        access_point_id = optional(string)
        iam             = optional(string)
      }))
    }))
  }))
  default = []
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - EPHEMERAL STORAGE
# ------------------------------------------------------------------------------

variable "ephemeral_storage_size_gib" {
  description = "Ephemeral storage size in GiB (Fargate only, 21-200)"
  type        = number
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - PROXY CONFIGURATION
# ------------------------------------------------------------------------------

variable "proxy_configuration" {
  description = "App Mesh proxy configuration"
  type = object({
    type           = optional(string, "APPMESH")
    container_name = string
    properties     = optional(map(string), {})
  })
  default = null
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES - PLACEMENT CONSTRAINTS
# ------------------------------------------------------------------------------

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
