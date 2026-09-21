# ElastiCache Memcached Module

Creates an ElastiCache Memcached cluster for distributed caching.

## Usage

### Basic Single-Node Memcached

```hcl
module "memcached" {
  source = "path/to/modules/elasticache-memcached"

  cluster_id = "my-memcached"

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.memcached_sg.id]

  tags = {
    Environment = "development"
    Project     = "my-app"
  }
}
```

### Multi-Node Memcached Cluster

```hcl
module "memcached" {
  source = "path/to/modules/elasticache-memcached"

  cluster_id      = "my-memcached-cluster"
  node_type       = "cache.r6g.large"
  num_cache_nodes = 3
  az_mode         = "cross-az"

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.memcached_sg.id]

  tags = {
    Environment = "production"
  }
}
```

### Memcached with Specific AZs

```hcl
module "memcached" {
  source = "path/to/modules/elasticache-memcached"

  cluster_id      = "my-memcached"
  node_type       = "cache.t3.medium"
  num_cache_nodes = 3
  az_mode         = "cross-az"

  preferred_availability_zones = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.memcached_sg.id]
}
```

### Memcached with Custom Parameters

```hcl
module "memcached" {
  source = "path/to/modules/elasticache-memcached"

  cluster_id = "my-custom-memcached"
  node_type  = "cache.r6g.large"

  parameter_group_family = "memcached1.6"
  parameters = [
    {
      name  = "max_item_size"
      value = "10485760"  # 10MB
    },
    {
      name  = "chunk_size"
      value = "48"
    }
  ]

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.memcached_sg.id]
}
```

### Memcached with SNS Notifications

```hcl
module "memcached" {
  source = "path/to/modules/elasticache-memcached"

  cluster_id      = "my-memcached"
  num_cache_nodes = 2
  az_mode         = "cross-az"

  notification_topic_arn = aws_sns_topic.cache_notifications.arn

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.memcached_sg.id]
}
```

## Features

- **Distributed Caching**: Spread data across multiple nodes
- **Cross-AZ**: Deploy nodes across availability zones
- **Auto Discovery**: Configuration endpoint for automatic node discovery
- **Parameters**: Custom parameter groups
- **Notifications**: SNS topic integration

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_id | ID of the Memcached cluster | `string` | n/a | yes |
| engine_version | Memcached engine version | `string` | `"1.6.22"` | no |
| node_type | Node type | `string` | `"cache.t3.micro"` | no |
| port | Port number | `number` | `11211` | no |
| num_cache_nodes | Number of cache nodes | `number` | `1` | no |
| az_mode | AZ mode (single-az or cross-az) | `string` | `"single-az"` | no |
| preferred_availability_zones | Preferred AZs for cache nodes | `list(string)` | `[]` | no |
| subnet_ids | Subnet IDs for subnet group | `list(string)` | `[]` | no |
| security_group_ids | Security group IDs | `list(string)` | `[]` | no |
| parameter_group_family | Parameter group family | `string` | `""` | no |
| parameters | List of parameters | `list(object)` | `[]` | no |
| maintenance_window | Preferred maintenance window | `string` | `"sun:05:00-sun:06:00"` | no |
| notification_topic_arn | SNS topic ARN for notifications | `string` | `""` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The cluster ID |
| arn | The ARN of the cluster |
| cluster_id | The cluster ID |
| configuration_endpoint | The configuration endpoint address |
| cluster_address | The DNS name of the cluster |
| port | The port number |
| cache_nodes | List of cache node information |
| connection_string | Memcached connection string |

## Node Types

| Category | Types |
|----------|-------|
| General Purpose | cache.t3.*, cache.t4g.* |
| Memory Optimized | cache.r6g.*, cache.r7g.*, cache.m6g.*, cache.m7g.* |

## Memcached vs Redis

| Feature | Memcached | Redis |
|---------|-----------|-------|
| Data Structures | Simple key-value | Rich (strings, lists, sets, etc.) |
| Persistence | No | Yes |
| Replication | No | Yes |
| Pub/Sub | No | Yes |
| Transactions | No | Yes |
| Multithreading | Yes | No |
| Memory Efficiency | Higher | Lower |
| Use Case | Simple caching | Complex caching, sessions, queues |

## Auto Discovery

Memcached clusters support auto discovery, which allows your application to automatically discover cache nodes. Use the `configuration_endpoint` output to connect:

```python
# Python example with pymemcache
from pymemcache.client.hash import HashClient
from pymemcache.client.murmur3 import murmur3_32

client = HashClient.from_config(
    'my-memcached.abc123.cfg.use1.cache.amazonaws.com:11211'
)
```

```javascript
// Node.js example with memcached
const Memcached = require('memcached');
const memcached = new Memcached('my-memcached.abc123.cfg.use1.cache.amazonaws.com:11211');
```
