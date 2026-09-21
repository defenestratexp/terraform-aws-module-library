# AWS Modules

Individual AWS resource modules for infrastructure deployment. All modules follow consistent patterns and are designed to be composable.

## Module Count: 57

### Foundation (4)
| Module | Description |
|--------|-------------|
| [terraform-state](./terraform-state) | S3 + DynamoDB for Terraform state management |
| [vpc](./vpc) | VPC with subnets, internet gateway, route tables |
| [nat-gateway](./nat-gateway) | NAT gateway for private subnet outbound |
| [security-group](./security-group) | Security group with flexible rules |

### Compute & Load Balancing (6)
| Module | Description |
|--------|-------------|
| [ec2-instance](./ec2-instance) | Single EC2 instance |
| [launch-template](./launch-template) | EC2 launch template for ASG |
| [asg](./asg) | Auto Scaling Group |
| [alb](./alb) | Application Load Balancer |
| [nlb](./nlb) | Network Load Balancer |
| [target-group](./target-group) | Load balancer target group |

### Storage & Database (8)
| Module | Description |
|--------|-------------|
| [s3-bucket](./s3-bucket) | S3 bucket with encryption, versioning, lifecycle |
| [efs](./efs) | Elastic File System |
| [ebs-volume](./ebs-volume) | Standalone EBS volume |
| [rds-instance](./rds-instance) | Single RDS instance |
| [rds-aurora](./rds-aurora) | Aurora cluster |
| [dynamodb-table](./dynamodb-table) | DynamoDB table |
| [elasticache-redis](./elasticache-redis) | ElastiCache Redis cluster |
| [elasticache-memcached](./elasticache-memcached) | ElastiCache Memcached cluster |

### Security & Identity (7)
| Module | Description |
|--------|-------------|
| [iam-role](./iam-role) | IAM role with assume role policy |
| [iam-policy](./iam-policy) | Standalone IAM policy |
| [iam-user](./iam-user) | IAM user (for service accounts) |
| [iam-instance-profile](./iam-instance-profile) | Instance profile for EC2 |
| [kms-key](./kms-key) | KMS encryption key |
| [secrets-manager](./secrets-manager) | Secrets Manager secret |
| [acm-certificate](./acm-certificate) | ACM SSL/TLS certificate |

### Networking Extended (8)
| Module | Description |
|--------|-------------|
| [route53-zone](./route53-zone) | Route53 hosted zone |
| [route53-records](./route53-records) | Route53 DNS records |
| [cloudfront](./cloudfront) | CloudFront distribution |
| [vpc-endpoints](./vpc-endpoints) | VPC endpoints (S3, DynamoDB, SSM, etc.) |
| [vpc-peering](./vpc-peering) | VPC peering connection |
| [transit-gateway](./transit-gateway) | Transit Gateway |
| [transit-gateway-attachment](./transit-gateway-attachment) | TGW VPC attachment |
| [vpn-gateway](./vpn-gateway) | VPN Gateway |

### Containers (6)
| Module | Description |
|--------|-------------|
| [ecr-repository](./ecr-repository) | ECR container registry |
| [ecs-cluster](./ecs-cluster) | ECS cluster (Fargate or EC2) |
| [ecs-service](./ecs-service) | ECS service with task definition |
| [ecs-task-definition](./ecs-task-definition) | Standalone task definition |
| [eks-cluster](./eks-cluster) | EKS Kubernetes cluster |
| [eks-node-group](./eks-node-group) | EKS managed node group |

### Serverless (6)
| Module | Description |
|--------|-------------|
| [lambda](./lambda) | Lambda function |
| [lambda-layer](./lambda-layer) | Lambda layer |
| [api-gateway-rest](./api-gateway-rest) | REST API Gateway |
| [api-gateway-http](./api-gateway-http) | HTTP API Gateway (v2) |
| [step-functions](./step-functions) | Step Functions state machine |
| [eventbridge-rule](./eventbridge-rule) | EventBridge rule |

### Messaging (3)
| Module | Description |
|--------|-------------|
| [sqs-queue](./sqs-queue) | SQS queue |
| [sns-topic](./sns-topic) | SNS topic |
| [sns-subscription](./sns-subscription) | SNS subscription |

### Monitoring & Logging (4)
| Module | Description |
|--------|-------------|
| [cloudwatch-log-group](./cloudwatch-log-group) | CloudWatch log group |
| [cloudwatch-alarm](./cloudwatch-alarm) | CloudWatch alarm |
| [cloudwatch-dashboard](./cloudwatch-dashboard) | CloudWatch dashboard |
| [vpc-flow-logs](./vpc-flow-logs) | VPC flow logs |

### Data & Analytics (5)
| Module | Description |
|--------|-------------|
| [redshift-cluster](./redshift-cluster) | Redshift data warehouse |
| [kinesis-stream](./kinesis-stream) | Kinesis data stream |
| [kinesis-firehose](./kinesis-firehose) | Kinesis Firehose delivery stream |
| [glue-catalog-database](./glue-catalog-database) | Glue catalog database |
| [athena-workgroup](./athena-workgroup) | Athena workgroup |

## Module Standards

All modules follow these conventions:

### Required Files
- `versions.tf` - Terraform >= 1.5.0, AWS provider >= 5.0.0
- `variables.tf` - Input variables with descriptions and validation
- `main.tf` - Resource definitions
- `outputs.tf` - Useful outputs for composition
- `README.md` - Usage documentation with examples

### Standard Tags
```hcl
ManagedBy = "terraform"
Module    = "{module-name}"
```

### Naming Convention
Resources follow the pattern: `{name}[-{descriptor}]`

## Usage

```hcl
module "vpc" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/vpc"

  name               = "acme-prod"
  cidr_block         = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  tags = {
    Environment = "production"
  }
}
```
