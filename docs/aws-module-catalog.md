# AWS Module Catalog

Master checklist of AWS modules for this module library.

## Build Order

Modules are built in dependency order - foundational modules first, then modules that depend on them.

### Phase 1: Foundation
- [x] `terraform-state` - S3 + DynamoDB for state management
- [x] `vpc` - VPC with subnets, internet gateway, route tables
- [x] `nat-gateway` - NAT gateway for private subnet outbound
- [x] `security-group` - Security group with flexible rules

### Phase 2: Compute & Load Balancing
- [x] `ec2-instance` - Single EC2 instance
- [x] `launch-template` - EC2 launch template for ASG
- [x] `asg` - Auto Scaling Group
- [x] `alb` - Application Load Balancer
- [x] `nlb` - Network Load Balancer
- [x] `target-group` - Load balancer target group

### Phase 3: Storage & Database
- [x] `s3-bucket` - S3 bucket with encryption, versioning, lifecycle
- [x] `efs` - Elastic File System
- [x] `ebs-volume` - Standalone EBS volume
- [x] `rds-instance` - Single RDS instance
- [x] `rds-aurora` - Aurora cluster
- [x] `dynamodb-table` - DynamoDB table
- [x] `elasticache-redis` - ElastiCache Redis cluster
- [x] `elasticache-memcached` - ElastiCache Memcached cluster

### Phase 4: Security & Identity
- [x] `iam-role` - IAM role with assume role policy
- [x] `iam-policy` - Standalone IAM policy
- [x] `iam-user` - IAM user (for service accounts)
- [x] `iam-instance-profile` - Instance profile for EC2
- [x] `kms-key` - KMS encryption key
- [x] `secrets-manager` - Secrets Manager secret
- [x] `acm-certificate` - ACM SSL/TLS certificate

### Phase 5: Networking Extended
- [x] `route53-zone` - Route53 hosted zone
- [x] `route53-records` - Route53 DNS records
- [x] `cloudfront` - CloudFront distribution
- [x] `vpc-endpoints` - VPC endpoints (S3, DynamoDB, SSM, etc.)
- [x] `vpc-peering` - VPC peering connection
- [x] `transit-gateway` - Transit Gateway
- [x] `transit-gateway-attachment` - TGW VPC attachment
- [x] `vpn-gateway` - VPN Gateway

### Phase 6: Containers
- [x] `ecr-repository` - ECR container registry
- [x] `ecs-cluster` - ECS cluster (Fargate or EC2)
- [x] `ecs-service` - ECS service with task definition
- [x] `ecs-task-definition` - Standalone task definition
- [x] `eks-cluster` - EKS Kubernetes cluster
- [x] `eks-node-group` - EKS managed node group

### Phase 7: Serverless
- [x] `lambda` - Lambda function
- [x] `lambda-layer` - Lambda layer
- [x] `api-gateway-rest` - REST API Gateway
- [x] `api-gateway-http` - HTTP API Gateway (v2)
- [x] `step-functions` - Step Functions state machine
- [x] `eventbridge-rule` - EventBridge rule

### Phase 8: Messaging
- [x] `sqs-queue` - SQS queue
- [x] `sns-topic` - SNS topic
- [x] `sns-subscription` - SNS subscription

### Phase 9: Monitoring & Logging
- [x] `cloudwatch-log-group` - CloudWatch log group
- [x] `cloudwatch-alarm` - CloudWatch alarm
- [x] `cloudwatch-dashboard` - CloudWatch dashboard
- [x] `vpc-flow-logs` - VPC flow logs

### Phase 10: Data & Analytics
- [x] `redshift-cluster` - Redshift data warehouse
- [x] `kinesis-stream` - Kinesis data stream
- [x] `kinesis-firehose` - Kinesis Firehose delivery stream
- [x] `glue-catalog-database` - Glue catalog database
- [x] `athena-workgroup` - Athena workgroup

---

## Module Count by Category

| Category | Count | Status |
|----------|-------|--------|
| Foundation | 4 | 4 complete |
| Compute & Load Balancing | 6 | 6 complete |
| Storage & Database | 8 | 8 complete |
| Security & Identity | 7 | 7 complete |
| Networking Extended | 8 | 8 complete |
| Containers | 6 | 6 complete |
| Serverless | 6 | 6 complete |
| Messaging | 3 | 3 complete |
| Monitoring & Logging | 4 | 4 complete |
| Data & Analytics | 5 | 5 complete |
| **Total** | **57** | **57 complete** |

---

## Module Interface Standards

All modules follow these conventions (see `docs/naming-conventions.md` for details):

### Required Files
- `main.tf` - Primary resource definitions
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `versions.tf` - Provider and Terraform version constraints
- `README.md` - Usage documentation

### Required Variables (where applicable)
- `name` - Resource name/identifier
- `tags` - Additional tags (map)

### Required Outputs (where applicable)
- `id` - Primary resource ID
- `arn` - Resource ARN
- `name` - Resource name

### Naming Pattern
Resources are named: `{name}` or `{name}-{descriptor}`

Example: If `name = "acme-prod"`, resources become:
- VPC: `acme-prod`
- Public subnets: `acme-prod-public-1`, `acme-prod-public-2`
- NAT Gateway: `acme-prod-nat-1`
