# Step Functions State Machine Module

Creates an AWS Step Functions state machine with IAM role, logging, and tracing.

## Usage

### Basic State Machine

```hcl
module "state_machine" {
  source = "path/to/modules/step-functions"

  name = "order-processor"

  definition = jsonencode({
    Comment = "Order processing workflow"
    StartAt = "ValidateOrder"
    States = {
      ValidateOrder = {
        Type     = "Task"
        Resource = module.validate_lambda.arn
        Next     = "ProcessPayment"
      }
      ProcessPayment = {
        Type     = "Task"
        Resource = module.payment_lambda.arn
        Next     = "FulfillOrder"
      }
      FulfillOrder = {
        Type     = "Task"
        Resource = module.fulfill_lambda.arn
        End      = true
      }
    }
  })

  tags = {
    Environment = "production"
  }
}
```

### State Machine with Logging

```hcl
module "state_machine" {
  source = "path/to/modules/step-functions"

  name = "logged-workflow"

  definition = jsonencode({
    StartAt = "FirstStep"
    States = {
      FirstStep = {
        Type     = "Task"
        Resource = module.lambda.arn
        End      = true
      }
    }
  })

  create_log_group         = true
  log_group_retention_days = 30

  logging_configuration = {
    level                  = "ALL"
    include_execution_data = true
  }

  tags = {
    Environment = "production"
  }
}
```

### Express State Machine

```hcl
module "state_machine" {
  source = "path/to/modules/step-functions"

  name = "high-volume-processor"
  type = "EXPRESS"

  definition = jsonencode({
    StartAt = "Process"
    States = {
      Process = {
        Type     = "Task"
        Resource = module.lambda.arn
        End      = true
      }
    }
  })

  # Express workflows require logging
  create_log_group = true
  logging_configuration = {
    level                  = "ALL"
    include_execution_data = false
  }

  tags = {
    Environment = "production"
  }
}
```

### State Machine with Custom IAM Role

```hcl
module "state_machine" {
  source = "path/to/modules/step-functions"

  name = "custom-role-workflow"

  definition = jsonencode({
    StartAt = "InvokeLambda"
    States = {
      InvokeLambda = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = module.lambda.arn
          Payload = {
            "input.$" = "$"
          }
        }
        End = true
      }
    }
  })

  # Grant permissions to invoke Lambda
  role_inline_policies = {
    lambda = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "lambda:InvokeFunction"
          Resource = module.lambda.arn
        }
      ]
    })
  }

  tags = {
    Environment = "production"
  }
}
```

### State Machine with X-Ray Tracing

```hcl
module "state_machine" {
  source = "path/to/modules/step-functions"

  name = "traced-workflow"

  definition = jsonencode({
    StartAt = "Step1"
    States = {
      Step1 = {
        Type     = "Task"
        Resource = module.lambda.arn
        End      = true
      }
    }
  })

  tracing_enabled = true

  tags = {
    Environment = "production"
  }
}
```

### State Machine with Encryption

```hcl
module "state_machine" {
  source = "path/to/modules/step-functions"

  name = "encrypted-workflow"

  definition = jsonencode({
    StartAt = "Process"
    States = {
      Process = {
        Type     = "Task"
        Resource = module.lambda.arn
        End      = true
      }
    }
  })

  encryption_configuration = {
    kms_key_id                        = module.kms_key.id
    kms_data_key_reuse_period_seconds = 300
  }

  tags = {
    Environment = "production"
  }
}
```

### Complex Workflow with Parallel States

```hcl
module "state_machine" {
  source = "path/to/modules/step-functions"

  name = "parallel-workflow"

  definition = jsonencode({
    Comment = "Parallel processing workflow"
    StartAt = "Parallel"
    States = {
      Parallel = {
        Type = "Parallel"
        Branches = [
          {
            StartAt = "Branch1"
            States = {
              Branch1 = {
                Type     = "Task"
                Resource = module.branch1_lambda.arn
                End      = true
              }
            }
          },
          {
            StartAt = "Branch2"
            States = {
              Branch2 = {
                Type     = "Task"
                Resource = module.branch2_lambda.arn
                End      = true
              }
            }
          }
        ]
        Next = "Aggregate"
      }
      Aggregate = {
        Type     = "Task"
        Resource = module.aggregate_lambda.arn
        End      = true
      }
    }
  })

  role_inline_policies = {
    lambda = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = "lambda:InvokeFunction"
          Resource = [
            module.branch1_lambda.arn,
            module.branch2_lambda.arn,
            module.aggregate_lambda.arn
          ]
        }
      ]
    })
  }

  tags = {
    Environment = "production"
  }
}
```

### State Machine with Wait and Choice States

```hcl
module "state_machine" {
  source = "path/to/modules/step-functions"

  name = "approval-workflow"

  definition = jsonencode({
    StartAt = "SubmitRequest"
    States = {
      SubmitRequest = {
        Type     = "Task"
        Resource = module.submit_lambda.arn
        Next     = "WaitForApproval"
      }
      WaitForApproval = {
        Type    = "Wait"
        Seconds = 300
        Next    = "CheckStatus"
      }
      CheckStatus = {
        Type     = "Task"
        Resource = module.check_lambda.arn
        Next     = "IsApproved"
      }
      IsApproved = {
        Type = "Choice"
        Choices = [
          {
            Variable      = "$.status"
            StringEquals  = "approved"
            Next          = "ProcessApproved"
          },
          {
            Variable      = "$.status"
            StringEquals  = "rejected"
            Next          = "ProcessRejected"
          }
        ]
        Default = "WaitForApproval"
      }
      ProcessApproved = {
        Type     = "Task"
        Resource = module.approved_lambda.arn
        End      = true
      }
      ProcessRejected = {
        Type     = "Task"
        Resource = module.rejected_lambda.arn
        End      = true
      }
    }
  })

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Standard Workflows**: Long-running, exactly-once execution
- **Express Workflows**: High-volume, at-least-once execution
- **Logging**: CloudWatch Logs integration
- **Tracing**: X-Ray distributed tracing
- **Encryption**: KMS encryption for data at rest
- **Versioning**: Publish and alias support

## Standard vs Express

| Feature | Standard | Express |
|---------|----------|---------|
| Duration | Up to 1 year | Up to 5 minutes |
| Execution | Exactly-once | At-least-once |
| Pricing | Per state transition | Per execution + duration |
| History | Full execution history | CloudWatch Logs only |
| Use Case | Long-running workflows | High-volume processing |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | State machine name | `string` | n/a | yes |
| definition | ASL definition JSON | `string` | n/a | yes |
| type | STANDARD or EXPRESS | `string` | `"STANDARD"` | no |
| publish | Publish a version | `bool` | `false` | no |
| create_role | Create IAM role | `bool` | `true` | no |
| role_policies | Policy ARNs to attach | `map(string)` | `{}` | no |
| role_inline_policies | Inline policies | `map(string)` | `{}` | no |
| logging_configuration | Logging configuration | `object` | `null` | no |
| create_log_group | Create log group | `bool` | `false` | no |
| tracing_enabled | Enable X-Ray tracing | `bool` | `false` | no |
| encryption_configuration | Encryption config | `object` | `null` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | State machine ID |
| arn | State machine ARN |
| name | State machine name |
| status | State machine status |
| role_arn | IAM role ARN |
| log_group_name | CloudWatch log group name |

## Considerations

- Grant the state machine role permissions to invoke resources
- Express workflows require CloudWatch Logs configuration
- Standard workflows store full execution history
- Use X-Ray tracing for debugging complex workflows
