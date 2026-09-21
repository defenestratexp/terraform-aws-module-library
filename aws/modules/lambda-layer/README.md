# Lambda Layer Module

Creates an AWS Lambda layer for sharing code and dependencies across functions.

## Usage

### Basic Layer from Directory

```hcl
module "lambda_layer" {
  source = "path/to/modules/lambda-layer"

  layer_name          = "common-utils"
  compatible_runtimes = ["nodejs20.x", "nodejs18.x"]
  source_path         = "${path.module}/layers/common-utils"
}
```

### Python Dependencies Layer

```hcl
module "python_deps_layer" {
  source = "path/to/modules/lambda-layer"

  layer_name          = "python-dependencies"
  compatible_runtimes = ["python3.12", "python3.11"]
  source_path         = "${path.module}/layers/python-deps"

  description = "Common Python dependencies"
}
```

### Layer from Zip File

```hcl
module "lambda_layer" {
  source = "path/to/modules/lambda-layer"

  layer_name          = "my-layer"
  compatible_runtimes = ["nodejs20.x"]
  filename            = "${path.module}/layers/my-layer.zip"
}
```

### Layer from S3

```hcl
module "lambda_layer" {
  source = "path/to/modules/lambda-layer"

  layer_name          = "shared-layer"
  compatible_runtimes = ["nodejs20.x"]

  s3_bucket         = "my-deployment-bucket"
  s3_key            = "layers/shared-layer.zip"
  s3_object_version = "abc123"
}
```

### ARM64 Layer

```hcl
module "lambda_layer" {
  source = "path/to/modules/lambda-layer"

  layer_name               = "arm-layer"
  compatible_runtimes      = ["nodejs20.x"]
  compatible_architectures = ["arm64"]
  source_path              = "${path.module}/layers/arm-layer"
}
```

### Multi-Architecture Layer

```hcl
module "lambda_layer" {
  source = "path/to/modules/lambda-layer"

  layer_name               = "universal-layer"
  compatible_runtimes      = ["nodejs20.x"]
  compatible_architectures = ["x86_64", "arm64"]
  source_path              = "${path.module}/layers/universal"
}
```

### Layer with Public Access

```hcl
module "lambda_layer" {
  source = "path/to/modules/lambda-layer"

  layer_name          = "public-layer"
  compatible_runtimes = ["nodejs20.x"]
  source_path         = "${path.module}/layers/public"

  license_info = "MIT"

  permission_statements = {
    public = {
      principal = "*"
    }
  }
}
```

### Layer with Organization Access

```hcl
module "lambda_layer" {
  source = "path/to/modules/lambda-layer"

  layer_name          = "org-shared-layer"
  compatible_runtimes = ["nodejs20.x"]
  source_path         = "${path.module}/layers/org-shared"

  permission_statements = {
    organization = {
      principal       = "*"
      organization_id = "o-1234567890"
    }
  }
}
```

### Layer with Cross-Account Access

```hcl
module "lambda_layer" {
  source = "path/to/modules/lambda-layer"

  layer_name          = "shared-layer"
  compatible_runtimes = ["nodejs20.x"]
  source_path         = "${path.module}/layers/shared"

  permission_statements = {
    dev_account = {
      principal = "111111111111"
    }
    staging_account = {
      principal = "222222222222"
    }
  }
}
```

### Layer with Version Retention

```hcl
module "lambda_layer" {
  source = "path/to/modules/lambda-layer"

  layer_name          = "versioned-layer"
  compatible_runtimes = ["nodejs20.x"]
  source_path         = "${path.module}/layers/versioned"

  # Keep old versions when creating new ones
  skip_destroy = true
}
```

### Using Layer in Lambda Function

```hcl
module "lambda_layer" {
  source = "path/to/modules/lambda-layer"

  layer_name          = "common-utils"
  compatible_runtimes = ["nodejs20.x"]
  source_path         = "${path.module}/layers/common-utils"
}

module "lambda" {
  source = "path/to/modules/lambda"

  function_name = "my-function"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  source_path   = "${path.module}/src"

  layers = [module.lambda_layer.arn]
}
```

## Layer Directory Structure

Layers must follow a specific directory structure:

### Node.js
```
layer/
└── nodejs/
    └── node_modules/
        └── ...
```

### Python
```
layer/
└── python/
    └── lib/
        └── python3.x/
            └── site-packages/
                └── ...
```

### Other Runtimes
```
layer/
├── bin/          # Executables
└── lib/          # Shared libraries
```

## Features

- **Code Sharing**: Share code across multiple Lambda functions
- **Dependency Management**: Package dependencies separately from function code
- **Version Control**: Each update creates a new version
- **Cross-Account Sharing**: Share layers with other AWS accounts
- **Multi-Architecture**: Support both x86_64 and ARM64

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |
| archive | >= 2.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| layer_name | Layer name | `string` | n/a | yes |
| compatible_runtimes | Compatible runtimes | `list(string)` | n/a | yes |
| source_path | Path to source directory | `string` | `null` | no |
| filename | Path to zip file | `string` | `null` | no |
| s3_bucket | S3 bucket for package | `string` | `null` | no |
| s3_key | S3 key for package | `string` | `null` | no |
| s3_object_version | S3 object version | `string` | `null` | no |
| description | Layer description | `string` | `""` | no |
| compatible_architectures | Compatible architectures | `list(string)` | `["x86_64"]` | no |
| license_info | License information | `string` | `null` | no |
| permission_statements | Access permissions | `map(object)` | `{}` | no |
| skip_destroy | Keep old versions | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | Layer ARN with version |
| layer_arn | Layer ARN without version |
| version | Layer version number |
| layer_name | Layer name |
| source_code_hash | Source code hash |
| source_code_size | Source code size |
| created_date | Creation date |
| compatible_runtimes | Compatible runtimes |
| compatible_architectures | Compatible architectures |

## Considerations

- Maximum layer size: 50MB (zipped), 250MB (unzipped)
- Maximum 5 layers per function
- Layers add to function cold start time
- Use `skip_destroy = true` to keep old versions for rollback
- Layer code is extracted to `/opt` in the Lambda environment
