# VPC Flow Logs Module

Creates VPC Flow Logs with CloudWatch Logs, S3, or Kinesis Firehose as the destination.

## Usage

### VPC Flow Logs to CloudWatch

```hcl
module "vpc_flow_logs" {
  source = "path/to/modules/vpc-flow-logs"

  name          = "my-vpc-flow-logs"
  resource_id   = module.vpc.id
  resource_type = "VPC"

  destination_type            = "cloud-watch-logs"
  log_group_retention_in_days = 30

  tags = {
    Environment = "production"
  }
}
```

### VPC Flow Logs to S3

```hcl
module "vpc_flow_logs" {
  source = "path/to/modules/vpc-flow-logs"

  name          = "my-vpc-flow-logs"
  resource_id   = module.vpc.id
  resource_type = "VPC"

  destination_type = "s3"
  s3_bucket_arn    = module.logs_bucket.arn
  s3_key_prefix    = "flow-logs/"

  tags = {
    Environment = "production"
  }
}
```

### S3 with Parquet Format

```hcl
module "vpc_flow_logs" {
  source = "path/to/modules/vpc-flow-logs"

  name          = "my-vpc-flow-logs"
  resource_id   = module.vpc.id
  resource_type = "VPC"

  destination_type           = "s3"
  s3_bucket_arn              = module.logs_bucket.arn
  file_format                = "parquet"
  hive_compatible_partitions = true
  per_hour_partition         = true

  tags = {
    Environment = "production"
  }
}
```

### VPC Flow Logs to Kinesis Firehose

```hcl
module "vpc_flow_logs" {
  source = "path/to/modules/vpc-flow-logs"

  name          = "my-vpc-flow-logs"
  resource_id   = module.vpc.id
  resource_type = "VPC"

  destination_type = "kinesis-data-firehose"
  firehose_arn     = module.firehose.arn

  tags = {
    Environment = "production"
  }
}
```

### Subnet Flow Logs

```hcl
module "subnet_flow_logs" {
  source = "path/to/modules/vpc-flow-logs"

  name          = "private-subnet-flow-logs"
  resource_id   = module.vpc.private_subnet_ids[0]
  resource_type = "Subnet"

  destination_type            = "cloud-watch-logs"
  log_group_retention_in_days = 14

  tags = {
    Environment = "production"
  }
}
```

### ENI Flow Logs

```hcl
module "eni_flow_logs" {
  source = "path/to/modules/vpc-flow-logs"

  name          = "critical-eni-flow-logs"
  resource_id   = aws_network_interface.critical.id
  resource_type = "NetworkInterface"

  destination_type         = "cloud-watch-logs"
  max_aggregation_interval = 60  # 1 minute for faster analysis

  tags = {
    Environment = "production"
  }
}
```

### Rejected Traffic Only

```hcl
module "vpc_flow_logs" {
  source = "path/to/modules/vpc-flow-logs"

  name          = "rejected-traffic-logs"
  resource_id   = module.vpc.id
  resource_type = "VPC"

  traffic_type     = "REJECT"
  destination_type = "cloud-watch-logs"

  tags = {
    Environment = "production"
  }
}
```

### Custom Log Format

```hcl
module "vpc_flow_logs" {
  source = "path/to/modules/vpc-flow-logs"

  name          = "custom-format-logs"
  resource_id   = module.vpc.id
  resource_type = "VPC"

  destination_type = "cloud-watch-logs"

  log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr}"

  tags = {
    Environment = "production"
  }
}
```

### With KMS Encryption

```hcl
module "vpc_flow_logs" {
  source = "path/to/modules/vpc-flow-logs"

  name          = "encrypted-flow-logs"
  resource_id   = module.vpc.id
  resource_type = "VPC"

  destination_type            = "cloud-watch-logs"
  log_group_retention_in_days = 90
  log_group_kms_key_id        = module.kms_key.arn

  tags = {
    Environment = "production"
  }
}
```

### Existing CloudWatch Log Group

```hcl
module "vpc_flow_logs" {
  source = "path/to/modules/vpc-flow-logs"

  name          = "my-vpc-flow-logs"
  resource_id   = module.vpc.id
  resource_type = "VPC"

  destination_type = "cloud-watch-logs"
  create_log_group = false
  log_group_name   = "/existing/log-group"

  # Also use existing IAM role
  create_iam_role = false
  iam_role_arn    = aws_iam_role.existing.arn

  tags = {
    Environment = "production"
  }
}
```

### Multiple Flow Logs for Same VPC

```hcl
# Accepted traffic to CloudWatch (short retention)
module "accept_logs" {
  source = "path/to/modules/vpc-flow-logs"

  name          = "accept-traffic"
  resource_id   = module.vpc.id
  resource_type = "VPC"

  traffic_type                = "ACCEPT"
  destination_type            = "cloud-watch-logs"
  log_group_retention_in_days = 7

  tags = {
    Environment = "production"
  }
}

# Rejected traffic to S3 (long retention for security)
module "reject_logs" {
  source = "path/to/modules/vpc-flow-logs"

  name          = "reject-traffic"
  resource_id   = module.vpc.id
  resource_type = "VPC"

  traffic_type     = "REJECT"
  destination_type = "s3"
  s3_bucket_arn    = module.security_logs_bucket.arn
  file_format      = "parquet"

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Multiple Destinations**: CloudWatch Logs, S3, or Kinesis Firehose
- **Traffic Filtering**: Monitor accepted, rejected, or all traffic
- **Custom Log Format**: Select specific fields to capture
- **S3 Options**: Parquet format, Hive partitions, hourly partitions
- **Encryption**: KMS encryption for CloudWatch Logs
- **Auto IAM Role**: Creates IAM role for CloudWatch destination

## Default Log Format Fields

```
version account-id interface-id srcaddr dstaddr srcport dstport protocol packets bytes start end action log-status
```

## Available Log Fields

| Field | Description |
|-------|-------------|
| `version` | VPC Flow Logs version |
| `account-id` | AWS account ID |
| `interface-id` | Network interface ID |
| `srcaddr` | Source IP address |
| `dstaddr` | Destination IP address |
| `srcport` | Source port |
| `dstport` | Destination port |
| `protocol` | IANA protocol number |
| `packets` | Number of packets |
| `bytes` | Number of bytes |
| `start` | Start time (Unix) |
| `end` | End time (Unix) |
| `action` | ACCEPT or REJECT |
| `log-status` | OK, NODATA, SKIPDATA |
| `vpc-id` | VPC ID |
| `subnet-id` | Subnet ID |
| `instance-id` | Instance ID |
| `tcp-flags` | TCP flags bitmask |
| `type` | Traffic type (IPv4, IPv6) |
| `pkt-srcaddr` | Packet source address |
| `pkt-dstaddr` | Packet destination address |
| `region` | AWS Region |
| `az-id` | Availability Zone ID |
| `sublocation-type` | Sublocation type |
| `sublocation-id` | Sublocation ID |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Flow log name | `string` | n/a | yes |
| resource_id | Resource ID to monitor | `string` | n/a | yes |
| resource_type | Resource type (VPC/Subnet/NetworkInterface) | `string` | n/a | yes |
| destination_type | Destination type | `string` | `"cloud-watch-logs"` | no |
| traffic_type | Traffic type (ACCEPT/REJECT/ALL) | `string` | `"ALL"` | no |
| max_aggregation_interval | Aggregation interval (60/600 seconds) | `number` | `600` | no |
| log_format | Custom log format | `string` | `null` | no |
| log_group_name | CloudWatch log group name | `string` | `null` | no |
| create_log_group | Create CloudWatch log group | `bool` | `true` | no |
| log_group_retention_in_days | Log group retention | `number` | `30` | no |
| log_group_kms_key_id | KMS key for log group | `string` | `null` | no |
| s3_bucket_arn | S3 bucket ARN | `string` | `null` | no |
| s3_key_prefix | S3 key prefix | `string` | `null` | no |
| firehose_arn | Kinesis Firehose ARN | `string` | `null` | no |
| create_iam_role | Create IAM role | `bool` | `true` | no |
| iam_role_arn | Existing IAM role ARN | `string` | `null` | no |
| file_format | S3 file format | `string` | `"plain-text"` | no |
| hive_compatible_partitions | Use Hive partitions | `bool` | `false` | no |
| per_hour_partition | Partition per hour | `bool` | `false` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Flow log ID |
| arn | Flow log ARN |
| name | Flow log name |
| log_group_arn | CloudWatch log group ARN |
| log_group_name | CloudWatch log group name |
| iam_role_arn | IAM role ARN |
| iam_role_name | IAM role name |

## Considerations

- Flow logs do not capture all IP traffic (DHCP, DNS to VPC, etc.)
- S3 destination has 5-10 minute delivery delay
- CloudWatch Logs has near real-time delivery
- Parquet format reduces storage costs significantly
- 60-second aggregation interval increases costs
- Multiple flow logs on the same resource are supported
