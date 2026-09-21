# Lambda Function Module

Creates an AWS Lambda function with IAM role, CloudWatch logging, and optional triggers.

## Usage

### Basic Lambda Function

```hcl
module "lambda" {
  source = "path/to/modules/lambda"

  function_name = "my-function"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  source_path   = "${path.module}/src"

  tags = {
    Environment = "production"
  }
}
```

### Lambda with Environment Variables

```hcl
module "lambda" {
  source = "path/to/modules/lambda"

  function_name = "api-handler"
  handler       = "main.handler"
  runtime       = "python3.12"
  source_path   = "${path.module}/src"

  memory_size = 256
  timeout     = 30

  environment_variables = {
    DATABASE_URL = "postgresql://..."
    LOG_LEVEL    = "INFO"
  }

  tags = {
    Environment = "production"
  }
}
```

### Lambda with VPC Access

```hcl
module "lambda" {
  source = "path/to/modules/lambda"

  function_name = "vpc-function"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  source_path   = "${path.module}/src"

  vpc_config = {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [module.lambda_sg.id]
  }

  tags = {
    Environment = "production"
  }
}
```

### Lambda with S3 Deployment Package

```hcl
module "lambda" {
  source = "path/to/modules/lambda"

  function_name = "s3-deployed"
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  s3_bucket         = "my-deployment-bucket"
  s3_key            = "functions/my-function.zip"
  s3_object_version = "abc123"

  tags = {
    Environment = "production"
  }
}
```

### Container-Based Lambda

```hcl
module "lambda" {
  source = "path/to/modules/lambda"

  function_name = "container-function"
  handler       = null
  runtime       = null
  package_type  = "Image"

  image_uri = "${module.ecr.repository_url}:latest"

  memory_size = 512
  timeout     = 60

  tags = {
    Environment = "production"
  }
}
```

### Lambda with Function URL

```hcl
module "lambda" {
  source = "path/to/modules/lambda"

  function_name = "url-function"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  source_path   = "${path.module}/src"

  create_function_url             = true
  function_url_authorization_type = "NONE"

  function_url_cors = {
    allow_origins = ["https://example.com"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["Content-Type"]
    max_age       = 3600
  }

  tags = {
    Environment = "production"
  }
}
```

### Lambda with API Gateway Trigger

```hcl
module "lambda" {
  source = "path/to/modules/lambda"

  function_name = "api-handler"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  source_path   = "${path.module}/src"

  allowed_triggers = {
    api_gateway = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Lambda with SQS Event Source

```hcl
module "lambda" {
  source = "path/to/modules/lambda"

  function_name = "sqs-processor"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  source_path   = "${path.module}/src"

  event_source_mappings = {
    sqs = {
      event_source_arn = module.sqs_queue.arn
      batch_size       = 10
    }
  }

  # Grant SQS permissions
  role_inline_policies = {
    sqs = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = module.sqs_queue.arn
      }]
    })
  }

  tags = {
    Environment = "production"
  }
}
```

### Lambda with DynamoDB Stream

```hcl
module "lambda" {
  source = "path/to/modules/lambda"

  function_name = "dynamodb-processor"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  source_path   = "${path.module}/src"

  event_source_mappings = {
    dynamodb = {
      event_source_arn  = module.dynamodb.stream_arn
      starting_position = "LATEST"
      batch_size        = 100
      filter_criteria = {
        filters = [
          { pattern = jsonencode({ eventName = ["INSERT", "MODIFY"] }) }
        ]
      }
    }
  }

  role_policies = {
    dynamodb = "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole"
  }

  tags = {
    Environment = "production"
  }
}
```

### Lambda with Layers

```hcl
module "lambda" {
  source = "path/to/modules/lambda"

  function_name = "layered-function"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  source_path   = "${path.module}/src"

  layers = [
    module.lambda_layer.arn,
    "arn:aws:lambda:us-east-1:123456789012:layer:common-utils:5"
  ]

  tags = {
    Environment = "production"
  }
}
```

### Lambda with X-Ray Tracing

```hcl
module "lambda" {
  source = "path/to/modules/lambda"

  function_name = "traced-function"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  source_path   = "${path.module}/src"

  tracing_mode = "Active"

  tags = {
    Environment = "production"
  }
}
```

### ARM64 Lambda (Graviton)

```hcl
module "lambda" {
  source = "path/to/modules/lambda"

  function_name = "arm-function"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  source_path   = "${path.module}/src"

  architectures = ["arm64"]

  tags = {
    Environment = "production"
  }
}
```

### Lambda with Dead Letter Queue

```hcl
module "lambda" {
  source = "path/to/modules/lambda"

  function_name = "dlq-function"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  source_path   = "${path.module}/src"

  dead_letter_config = {
    target_arn = module.dlq.arn
  }

  role_inline_policies = {
    dlq = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
        Resource = module.dlq.arn
      }]
    })
  }

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Multiple Deployment Options**: Source path, S3, or container images
- **IAM Role Management**: Automatic role creation with customizable policies
- **VPC Integration**: Deploy in VPC with private subnet access
- **Event Sources**: SQS, DynamoDB Streams, Kinesis, Kafka
- **Triggers**: API Gateway, CloudWatch Events, S3, SNS
- **Function URLs**: Direct HTTPS endpoint without API Gateway
- **Layers**: Code sharing across functions
- **Tracing**: X-Ray integration for distributed tracing

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |
| archive | >= 2.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| function_name | Function name | `string` | n/a | yes |
| handler | Function entrypoint | `string` | n/a | yes |
| runtime | Runtime environment | `string` | n/a | yes |
| source_path | Path to source code | `string` | `null` | no |
| s3_bucket | S3 bucket for package | `string` | `null` | no |
| s3_key | S3 key for package | `string` | `null` | no |
| image_uri | ECR image URI | `string` | `null` | no |
| memory_size | Memory in MB | `number` | `128` | no |
| timeout | Timeout in seconds | `number` | `3` | no |
| environment_variables | Environment variables | `map(string)` | `{}` | no |
| vpc_config | VPC configuration | `object` | `null` | no |
| create_role | Create IAM role | `bool` | `true` | no |
| role_policies | Policy ARNs to attach | `map(string)` | `{}` | no |
| layers | Layer ARNs | `list(string)` | `[]` | no |
| tracing_mode | X-Ray tracing mode | `string` | `null` | no |
| create_function_url | Create function URL | `bool` | `false` | no |
| allowed_triggers | Trigger permissions | `map(object)` | `{}` | no |
| event_source_mappings | Event source mappings | `map(object)` | `{}` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | Function ARN |
| function_name | Function name |
| invoke_arn | Invoke ARN (for API Gateway) |
| qualified_arn | Qualified ARN with version |
| version | Published version |
| role_arn | Execution role ARN |
| log_group_name | CloudWatch log group name |
| function_url | Function URL (if enabled) |

## Runtimes

Common runtimes: `nodejs20.x`, `nodejs18.x`, `python3.12`, `python3.11`, `java21`, `java17`, `dotnet8`, `ruby3.3`, `provided.al2023`

## Considerations

- Cold starts increase with VPC configuration
- ARM64 (Graviton) offers better price/performance
- Container images support up to 10GB
- Provisioned concurrency reduces cold starts
- Function URLs are simpler than API Gateway for simple use cases
