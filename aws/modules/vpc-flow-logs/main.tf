# ------------------------------------------------------------------------------
# VPC FLOW LOGS MODULE
# Creates VPC Flow Logs with CloudWatch, S3, or Kinesis Firehose destination
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  default_tags = {
    ManagedBy = "terraform"
    Module    = "vpc-flow-logs"
  }

  tags = merge(local.default_tags, var.tags)

  is_cloudwatch = var.destination_type == "cloud-watch-logs"
  is_s3         = var.destination_type == "s3"
  is_firehose   = var.destination_type == "kinesis-data-firehose"

  log_group_name = var.log_group_name != null ? var.log_group_name : "/vpc/flow-logs/${var.name}"

  # Determine the log destination ARN
  log_destination_arn = local.is_cloudwatch ? (
    var.create_log_group ? aws_cloudwatch_log_group.main[0].arn : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.log_group_name}"
  ) : local.is_s3 ? var.s3_bucket_arn : var.firehose_arn

  # Determine the IAM role ARN
  iam_role_arn = local.is_cloudwatch ? (
    var.create_iam_role ? aws_iam_role.flow_logs[0].arn : var.iam_role_arn
  ) : null
}

# ------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "main" {
  count = local.is_cloudwatch && var.create_log_group ? 1 : 0

  name              = local.log_group_name
  retention_in_days = var.log_group_retention_in_days
  kms_key_id        = var.log_group_kms_key_id

  tags = merge(local.tags, {
    Name = local.log_group_name
  })
}

# ------------------------------------------------------------------------------
# IAM ROLE FOR CLOUDWATCH LOGS
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "flow_logs_assume_role" {
  count = local.is_cloudwatch && var.create_iam_role ? 1 : 0

  statement {
    sid     = "AllowFlowLogsAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "flow_logs" {
  count = local.is_cloudwatch && var.create_iam_role ? 1 : 0

  name                 = "${var.name}-flow-logs"
  assume_role_policy   = data.aws_iam_policy_document.flow_logs_assume_role[0].json
  permissions_boundary = var.iam_role_permissions_boundary

  tags = merge(local.tags, {
    Name = "${var.name}-flow-logs"
  })
}

data "aws_iam_policy_document" "flow_logs" {
  count = local.is_cloudwatch && var.create_iam_role ? 1 : 0

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "flow_logs" {
  count = local.is_cloudwatch && var.create_iam_role ? 1 : 0

  name   = "flow-logs-policy"
  role   = aws_iam_role.flow_logs[0].id
  policy = data.aws_iam_policy_document.flow_logs[0].json
}

# ------------------------------------------------------------------------------
# VPC FLOW LOG
# ------------------------------------------------------------------------------

resource "aws_flow_log" "main" {
  log_destination_type = var.destination_type

  # Resource to monitor
  vpc_id    = var.resource_type == "VPC" ? var.resource_id : null
  subnet_id = var.resource_type == "Subnet" ? var.resource_id : null
  eni_id    = var.resource_type == "NetworkInterface" ? var.resource_id : null

  # Destination
  log_destination = local.is_cloudwatch ? null : local.log_destination_arn
  log_group_name  = local.is_cloudwatch ? local.log_group_name : null
  iam_role_arn    = local.iam_role_arn

  # Flow log settings
  traffic_type             = var.traffic_type
  max_aggregation_interval = var.max_aggregation_interval
  log_format               = var.log_format

  # S3 destination options
  dynamic "destination_options" {
    for_each = local.is_s3 ? [1] : []
    content {
      file_format                = var.file_format
      hive_compatible_partitions = var.hive_compatible_partitions
      per_hour_partition         = var.per_hour_partition
    }
  }

  tags = merge(local.tags, {
    Name = var.name
  })

  depends_on = [
    aws_cloudwatch_log_group.main,
    aws_iam_role_policy.flow_logs,
  ]
}
