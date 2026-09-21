# ------------------------------------------------------------------------------
# CLOUDWATCH DASHBOARD MODULE
# Creates a CloudWatch dashboard
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  # Use provided dashboard_body or build from widgets
  dashboard_body = var.dashboard_body != null ? var.dashboard_body : jsonencode({
    widgets = var.widgets
  })
}

# ------------------------------------------------------------------------------
# CLOUDWATCH DASHBOARD
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.dashboard_name
  dashboard_body = local.dashboard_body
}
