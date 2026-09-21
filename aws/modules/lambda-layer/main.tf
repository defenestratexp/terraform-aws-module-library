# ------------------------------------------------------------------------------
# LAMBDA LAYER MODULE
# Creates a Lambda layer for code sharing across functions
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  use_source_path = var.source_path != null
  use_s3          = var.s3_bucket != null && var.s3_key != null
}

# ------------------------------------------------------------------------------
# ARCHIVE SOURCE (if source_path provided)
# ------------------------------------------------------------------------------

data "archive_file" "source" {
  count = local.use_source_path ? 1 : 0

  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.module}/.terraform/tmp/${var.layer_name}.zip"
}

# ------------------------------------------------------------------------------
# LAMBDA LAYER
# ------------------------------------------------------------------------------

resource "aws_lambda_layer_version" "main" {
  layer_name = var.layer_name

  # Source
  filename          = local.use_source_path ? data.archive_file.source[0].output_path : var.filename
  source_code_hash  = local.use_source_path ? data.archive_file.source[0].output_base64sha256 : null
  s3_bucket         = local.use_s3 ? var.s3_bucket : null
  s3_key            = local.use_s3 ? var.s3_key : null
  s3_object_version = local.use_s3 ? var.s3_object_version : null

  # Configuration
  description              = var.description
  compatible_runtimes      = var.compatible_runtimes
  compatible_architectures = var.compatible_architectures
  license_info             = var.license_info
  skip_destroy             = var.skip_destroy
}

# ------------------------------------------------------------------------------
# LAYER PERMISSIONS
# ------------------------------------------------------------------------------

resource "aws_lambda_layer_version_permission" "main" {
  for_each = var.permission_statements

  layer_name      = aws_lambda_layer_version.main.layer_name
  version_number  = aws_lambda_layer_version.main.version
  statement_id    = each.key
  action          = "lambda:GetLayerVersion"
  principal       = each.value.principal
  organization_id = each.value.organization_id
}
