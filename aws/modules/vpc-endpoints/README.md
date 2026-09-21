# VPC Endpoints Module

Creates VPC endpoints for AWS services (Gateway and Interface types).

## Usage

### S3 and DynamoDB Gateway Endpoints

```hcl
module "vpc_endpoints" {
  source = "path/to/modules/vpc-endpoints"

  vpc_id = module.vpc.id

  gateway_endpoints = {
    s3 = {
      service         = "s3"
      route_table_ids = module.vpc.private_route_table_ids
    }

    dynamodb = {
      service         = "dynamodb"
      route_table_ids = module.vpc.private_route_table_ids
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Interface Endpoints for AWS Services

```hcl
module "vpc_endpoints" {
  source = "path/to/modules/vpc-endpoints"

  vpc_id = module.vpc.id

  default_subnet_ids         = module.vpc.private_subnet_ids
  default_security_group_ids = [module.vpc_endpoint_sg.id]

  interface_endpoints = {
    ssm = {
      service = "ssm"
    }

    ssmmessages = {
      service = "ssmmessages"
    }

    ec2messages = {
      service = "ec2messages"
    }

    ecr_api = {
      service = "ecr.api"
    }

    ecr_dkr = {
      service = "ecr.dkr"
    }

    logs = {
      service = "logs"
    }
  }
}
```

### Mixed Gateway and Interface Endpoints

```hcl
module "vpc_endpoints" {
  source = "path/to/modules/vpc-endpoints"

  vpc_id = module.vpc.id

  default_subnet_ids         = module.vpc.private_subnet_ids
  default_security_group_ids = [module.vpc_endpoint_sg.id]

  gateway_endpoints = {
    s3 = {
      service         = "s3"
      route_table_ids = concat(
        module.vpc.private_route_table_ids,
        module.vpc.public_route_table_ids
      )
    }
  }

  interface_endpoints = {
    secrets = {
      service = "secretsmanager"
    }

    kms = {
      service = "kms"
    }

    sts = {
      service = "sts"
    }
  }
}
```

### Endpoints with Custom Policies

```hcl
module "vpc_endpoints" {
  source = "path/to/modules/vpc-endpoints"

  vpc_id = module.vpc.id

  gateway_endpoints = {
    s3 = {
      service         = "s3"
      route_table_ids = module.vpc.private_route_table_ids
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid       = "AllowSpecificBuckets"
            Effect    = "Allow"
            Principal = "*"
            Action    = ["s3:GetObject", "s3:PutObject"]
            Resource  = [
              "arn:aws:s3:::my-bucket/*",
              "arn:aws:s3:::my-other-bucket/*"
            ]
          }
        ]
      })
    }
  }

  default_subnet_ids         = module.vpc.private_subnet_ids
  default_security_group_ids = [module.vpc_endpoint_sg.id]

  interface_endpoints = {
    ssm = {
      service = "ssm"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid       = "AllowSSM"
            Effect    = "Allow"
            Principal = "*"
            Action    = ["ssm:*"]
            Resource  = "*"
          }
        ]
      })
    }
  }
}
```

### EKS Private Cluster Endpoints

```hcl
module "eks_endpoints" {
  source = "path/to/modules/vpc-endpoints"

  vpc_id = module.vpc.id

  default_subnet_ids         = module.vpc.private_subnet_ids
  default_security_group_ids = [module.vpc_endpoint_sg.id]

  gateway_endpoints = {
    s3 = {
      service         = "s3"
      route_table_ids = module.vpc.private_route_table_ids
    }
  }

  interface_endpoints = {
    ecr_api = {
      service = "ecr.api"
    }
    ecr_dkr = {
      service = "ecr.dkr"
    }
    ec2 = {
      service = "ec2"
    }
    sts = {
      service = "sts"
    }
    logs = {
      service = "logs"
    }
    elasticloadbalancing = {
      service = "elasticloadbalancing"
    }
    autoscaling = {
      service = "autoscaling"
    }
  }
}
```

## Features

- **Gateway Endpoints**: S3 and DynamoDB (free)
- **Interface Endpoints**: All other AWS services
- **Custom Policies**: Restrict endpoint access
- **Private DNS**: Automatic DNS resolution
- **Default Settings**: Common subnet and security group configurations

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | VPC ID for the endpoints | `string` | n/a | yes |
| gateway_endpoints | Gateway endpoint configurations | `map(object)` | `{}` | no |
| interface_endpoints | Interface endpoint configurations | `map(object)` | `{}` | no |
| default_subnet_ids | Default subnet IDs for interface endpoints | `list(string)` | `[]` | no |
| default_security_group_ids | Default security groups for interface endpoints | `list(string)` | `[]` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| gateway_endpoints | Map of gateway endpoint details |
| interface_endpoints | Map of interface endpoint details |
| gateway_endpoint_ids | Map of gateway endpoint IDs |
| interface_endpoint_ids | Map of interface endpoint IDs |
| s3_endpoint_prefix_list_id | Prefix list ID for S3 endpoint |
| dynamodb_endpoint_prefix_list_id | Prefix list ID for DynamoDB endpoint |

## Common Services

### Gateway Endpoints (Free)
- `s3` - Amazon S3
- `dynamodb` - Amazon DynamoDB

### Interface Endpoints (Paid)
| Service | Endpoint Service Name |
|---------|----------------------|
| SSM | `ssm`, `ssmmessages`, `ec2messages` |
| ECR | `ecr.api`, `ecr.dkr` |
| CloudWatch | `logs`, `monitoring` |
| Secrets Manager | `secretsmanager` |
| KMS | `kms` |
| STS | `sts` |
| EC2 | `ec2` |
| ECS | `ecs`, `ecs-agent`, `ecs-telemetry` |
| SNS | `sns` |
| SQS | `sqs` |
| Lambda | `lambda` |
| API Gateway | `execute-api` |

## Security Group for Interface Endpoints

```hcl
module "vpc_endpoint_sg" {
  source = "path/to/modules/security-group"

  name   = "vpc-endpoints"
  vpc_id = module.vpc.id

  ingress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [module.vpc.cidr_block]
      description = "HTTPS from VPC"
    }
  ]
}
```
