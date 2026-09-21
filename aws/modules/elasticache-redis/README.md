# ElastiCache Redis Module

Creates an ElastiCache Redis replication group with support for cluster mode, encryption, and high availability.

## Usage

### Basic Single-Node Redis

```hcl
module "redis" {
  source = "path/to/modules/elasticache-redis"

  replication_group_id = "my-redis"

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.redis_sg.id]

  tags = {
    Environment = "development"
    Project     = "my-app"
  }
}
```

### High-Availability Redis (Multi-AZ)

```hcl
module "redis" {
  source = "path/to/modules/elasticache-redis"

  replication_group_id = "my-ha-redis"
  node_type            = "cache.r6g.large"
  engine_version       = "7.0"

  num_cache_clusters         = 3
  automatic_failover_enabled = true
  multi_az_enabled           = true

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.redis_sg.id]

  snapshot_retention_limit = 7

  tags = {
    Environment = "production"
  }
}
```

### Redis with Cluster Mode (Sharding)

```hcl
module "redis_cluster" {
  source = "path/to/modules/elasticache-redis"

  replication_group_id = "my-redis-cluster"
  node_type            = "cache.r6g.large"

  cluster_mode_enabled    = true
  num_node_groups         = 3
  replicas_per_node_group = 2

  automatic_failover_enabled = true

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.redis_sg.id]
}
```

### Redis with Authentication

```hcl
module "redis_auth" {
  source = "path/to/modules/elasticache-redis"

  replication_group_id = "my-secure-redis"
  node_type            = "cache.t3.medium"

  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  auth_token                 = var.redis_auth_token

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.redis_sg.id]
}
```

### Redis with Custom Parameters

```hcl
module "redis_custom" {
  source = "path/to/modules/elasticache-redis"

  replication_group_id = "my-custom-redis"
  node_type            = "cache.r6g.large"

  parameter_group_family = "redis7"
  parameters = [
    {
      name  = "maxmemory-policy"
      value = "allkeys-lru"
    },
    {
      name  = "timeout"
      value = "300"
    }
  ]

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.redis_sg.id]
}
```

### Redis with CloudWatch Logging

```hcl
module "redis_logged" {
  source = "path/to/modules/elasticache-redis"

  replication_group_id = "my-logged-redis"
  node_type            = "cache.r6g.large"

  log_delivery_configuration = [
    {
      destination      = aws_cloudwatch_log_group.redis_slow.name
      destination_type = "cloudwatch-logs"
      log_format       = "json"
      log_type         = "slow-log"
    },
    {
      destination      = aws_cloudwatch_log_group.redis_engine.name
      destination_type = "cloudwatch-logs"
      log_format       = "json"
      log_type         = "engine-log"
    }
  ]

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.redis_sg.id]
}
```

## Features

- **Replication**: Multiple cache clusters for read scaling
- **Cluster Mode**: Horizontal scaling with sharding
- **High Availability**: Multi-AZ with automatic failover
- **Encryption**: At-rest and in-transit encryption
- **Authentication**: Redis AUTH support
- **Parameters**: Custom parameter groups
- **Snapshots**: Automated backups
- **Logging**: CloudWatch Logs and Kinesis Firehose integration
- **Notifications**: SNS topic integration

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| replication_group_id | ID of the replication group | `string` | n/a | yes |
| engine_version | Redis engine version | `string` | `"7.0"` | no |
| node_type | Node type | `string` | `"cache.t3.micro"` | no |
| port | Port number | `number` | `6379` | no |
| num_cache_clusters | Number of cache clusters | `number` | `1` | no |
| automatic_failover_enabled | Enable automatic failover | `bool` | `false` | no |
| multi_az_enabled | Enable Multi-AZ | `bool` | `false` | no |
| cluster_mode_enabled | Enable cluster mode (sharding) | `bool` | `false` | no |
| num_node_groups | Number of shards (cluster mode) | `number` | `1` | no |
| replicas_per_node_group | Replicas per shard (cluster mode) | `number` | `1` | no |
| subnet_ids | Subnet IDs for subnet group | `list(string)` | `[]` | no |
| security_group_ids | Security group IDs | `list(string)` | `[]` | no |
| at_rest_encryption_enabled | Enable at-rest encryption | `bool` | `true` | no |
| transit_encryption_enabled | Enable in-transit encryption | `bool` | `true` | no |
| kms_key_id | KMS key for encryption | `string` | `""` | no |
| auth_token | Redis AUTH password | `string` | `""` | no |
| parameter_group_family | Parameter group family | `string` | `""` | no |
| parameters | List of parameters | `list(object)` | `[]` | no |
| snapshot_retention_limit | Days to retain snapshots | `number` | `0` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the replication group |
| arn | The ARN of the replication group |
| replication_group_id | The replication group ID |
| primary_endpoint_address | The primary endpoint address |
| reader_endpoint_address | The reader endpoint address |
| configuration_endpoint_address | The configuration endpoint (cluster mode) |
| port | The port number |
| member_clusters | The cluster member identities |
| connection_string | Redis connection string |

## Node Types

| Category | Types |
|----------|-------|
| General Purpose | cache.t3.micro, cache.t3.small, cache.t3.medium, cache.t4g.* |
| Memory Optimized | cache.r6g.*, cache.r7g.*, cache.m6g.*, cache.m7g.* |

## Cluster Mode vs Non-Cluster Mode

| Feature | Non-Cluster Mode | Cluster Mode |
|---------|------------------|--------------|
| Sharding | No | Yes |
| Max Nodes | 6 (1 primary + 5 replicas) | 500 nodes across 250 shards |
| Endpoint | Primary + Reader | Configuration endpoint |
| Scaling | Vertical only | Horizontal + Vertical |
