# ------------------------------------------------------------------------------
# ECS TASK DEFINITION MODULE
# Creates an ECS task definition with optional IAM roles
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "ecs-task-definition"
  }

  tags = merge(local.default_tags, var.tags)

  # Determine container definitions format
  container_definitions = try(
    jsonencode(var.container_definitions),
    var.container_definitions
  )

  # Use provided roles or created roles
  task_role_arn      = var.task_role_arn != null ? var.task_role_arn : (var.create_task_role ? aws_iam_role.task[0].arn : null)
  execution_role_arn = var.execution_role_arn != null ? var.execution_role_arn : (var.create_execution_role ? aws_iam_role.execution[0].arn : null)
}

# ------------------------------------------------------------------------------
# TASK IAM ROLE
# ------------------------------------------------------------------------------

resource "aws_iam_role" "task" {
  count = var.create_task_role ? 1 : 0

  name = "${var.family}-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "${var.family}-task"
  })
}

resource "aws_iam_role_policy_attachment" "task" {
  for_each = var.create_task_role ? var.task_role_policies : {}

  role       = aws_iam_role.task[0].name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "task_inline" {
  for_each = var.create_task_role ? var.task_role_inline_policies : {}

  name   = each.key
  role   = aws_iam_role.task[0].name
  policy = each.value
}

# ------------------------------------------------------------------------------
# EXECUTION IAM ROLE
# ------------------------------------------------------------------------------

resource "aws_iam_role" "execution" {
  count = var.create_execution_role ? 1 : 0

  name = "${var.family}-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "${var.family}-execution"
  })
}

resource "aws_iam_role_policy_attachment" "execution_default" {
  count = var.create_execution_role ? 1 : 0

  role       = aws_iam_role.execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "execution" {
  for_each = var.create_execution_role ? var.execution_role_policies : {}

  role       = aws_iam_role.execution[0].name
  policy_arn = each.value
}

# ------------------------------------------------------------------------------
# ECS TASK DEFINITION
# ------------------------------------------------------------------------------

resource "aws_ecs_task_definition" "main" {
  family                   = var.family
  container_definitions    = local.container_definitions
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  task_role_arn            = local.task_role_arn
  execution_role_arn       = local.execution_role_arn

  dynamic "runtime_platform" {
    for_each = var.runtime_platform != null ? [var.runtime_platform] : []
    content {
      operating_system_family = runtime_platform.value.operating_system_family
      cpu_architecture        = runtime_platform.value.cpu_architecture
    }
  }

  dynamic "volume" {
    for_each = var.volumes
    content {
      name      = volume.value.name
      host_path = volume.value.host_path

      dynamic "docker_volume_configuration" {
        for_each = volume.value.docker_volume_configuration != null ? [volume.value.docker_volume_configuration] : []
        content {
          scope         = docker_volume_configuration.value.scope
          autoprovision = docker_volume_configuration.value.autoprovision
          driver        = docker_volume_configuration.value.driver
          driver_opts   = docker_volume_configuration.value.driver_opts
          labels        = docker_volume_configuration.value.labels
        }
      }

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = efs_volume_configuration.value.root_directory
          transit_encryption      = efs_volume_configuration.value.transit_encryption
          transit_encryption_port = efs_volume_configuration.value.transit_encryption_port

          dynamic "authorization_config" {
            for_each = efs_volume_configuration.value.authorization_config != null ? [efs_volume_configuration.value.authorization_config] : []
            content {
              access_point_id = authorization_config.value.access_point_id
              iam             = authorization_config.value.iam
            }
          }
        }
      }
    }
  }

  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage_size_gib != null ? [var.ephemeral_storage_size_gib] : []
    content {
      size_in_gib = ephemeral_storage.value
    }
  }

  dynamic "proxy_configuration" {
    for_each = var.proxy_configuration != null ? [var.proxy_configuration] : []
    content {
      type           = proxy_configuration.value.type
      container_name = proxy_configuration.value.container_name
      properties     = proxy_configuration.value.properties
    }
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  tags = merge(local.tags, {
    Name = var.family
  })
}
