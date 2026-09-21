# EKS Node Group Module

Creates an Amazon EKS managed node group with IAM role and scaling configuration.

## Usage

### Basic Node Group

```hcl
module "eks_node_group" {
  source = "path/to/modules/eks-node-group"

  name         = "general"
  cluster_name = module.eks_cluster.name
  subnet_ids   = module.vpc.private_subnet_ids

  tags = {
    Environment = "production"
  }
}
```

### Node Group with Custom Sizing

```hcl
module "eks_node_group" {
  source = "path/to/modules/eks-node-group"

  name         = "workers"
  cluster_name = module.eks_cluster.name
  subnet_ids   = module.vpc.private_subnet_ids

  instance_types = ["t3.large", "t3.xlarge"]
  disk_size      = 50

  desired_size = 3
  min_size     = 2
  max_size     = 10

  tags = {
    Environment = "production"
  }
}
```

### Spot Instance Node Group

```hcl
module "eks_node_group_spot" {
  source = "path/to/modules/eks-node-group"

  name         = "spot-workers"
  cluster_name = module.eks_cluster.name
  subnet_ids   = module.vpc.private_subnet_ids

  capacity_type  = "SPOT"
  instance_types = ["t3.large", "t3.xlarge", "t3a.large", "t3a.xlarge"]

  desired_size = 3
  min_size     = 0
  max_size     = 20

  # Taint spot nodes
  taints = [
    {
      key    = "spot"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  ]

  labels = {
    "node-type" = "spot"
  }

  tags = {
    Environment = "production"
  }
}
```

### GPU Node Group

```hcl
module "eks_node_group_gpu" {
  source = "path/to/modules/eks-node-group"

  name         = "gpu-workers"
  cluster_name = module.eks_cluster.name
  subnet_ids   = module.vpc.private_subnet_ids

  ami_type       = "AL2_x86_64_GPU"
  instance_types = ["p3.2xlarge"]
  disk_size      = 100

  desired_size = 1
  min_size     = 0
  max_size     = 4

  taints = [
    {
      key    = "nvidia.com/gpu"
      effect = "NO_SCHEDULE"
    }
  ]

  labels = {
    "node-type"    = "gpu"
    "accelerator"  = "nvidia"
  }

  tags = {
    Environment = "production"
  }
}
```

### ARM64 (Graviton) Node Group

```hcl
module "eks_node_group_arm" {
  source = "path/to/modules/eks-node-group"

  name         = "arm-workers"
  cluster_name = module.eks_cluster.name
  subnet_ids   = module.vpc.private_subnet_ids

  ami_type       = "AL2_ARM_64"
  instance_types = ["t4g.medium", "t4g.large"]

  desired_size = 2
  min_size     = 1
  max_size     = 5

  labels = {
    "arch" = "arm64"
  }

  tags = {
    Environment = "production"
  }
}
```

### Bottlerocket Node Group

```hcl
module "eks_node_group_bottlerocket" {
  source = "path/to/modules/eks-node-group"

  name         = "bottlerocket-workers"
  cluster_name = module.eks_cluster.name
  subnet_ids   = module.vpc.private_subnet_ids

  ami_type       = "BOTTLEROCKET_x86_64"
  instance_types = ["t3.large"]

  desired_size = 2
  min_size     = 1
  max_size     = 5

  tags = {
    Environment = "production"
  }
}
```

### Node Group with SSH Access

```hcl
module "eks_node_group" {
  source = "path/to/modules/eks-node-group"

  name         = "debug-workers"
  cluster_name = module.eks_cluster.name
  subnet_ids   = module.vpc.private_subnet_ids

  remote_access = {
    ec2_ssh_key               = "my-ssh-key"
    source_security_group_ids = [module.bastion_sg.id]
  }

  tags = {
    Environment = "development"
  }
}
```

### Node Group with Custom Launch Template

```hcl
module "eks_node_group" {
  source = "path/to/modules/eks-node-group"

  name         = "custom-workers"
  cluster_name = module.eks_cluster.name
  subnet_ids   = module.vpc.private_subnet_ids

  use_custom_launch_template = true
  launch_template_id         = aws_launch_template.custom.id
  launch_template_version    = aws_launch_template.custom.latest_version

  desired_size = 2
  min_size     = 1
  max_size     = 5

  tags = {
    Environment = "production"
  }
}
```

### Node Group with Additional IAM Policies

```hcl
module "eks_node_group" {
  source = "path/to/modules/eks-node-group"

  name         = "workers"
  cluster_name = module.eks_cluster.name
  subnet_ids   = module.vpc.private_subnet_ids

  # Add SSM and CloudWatch policies
  node_role_policies = {
    ssm        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    cloudwatch = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  }

  tags = {
    Environment = "production"
  }
}
```

### Multiple Node Groups

```hcl
locals {
  node_groups = {
    general = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      min_size       = 1
      max_size       = 5
      labels         = { "workload" = "general" }
    }
    compute = {
      instance_types = ["c5.xlarge"]
      desired_size   = 2
      min_size       = 0
      max_size       = 10
      labels         = { "workload" = "compute" }
    }
    memory = {
      instance_types = ["r5.large"]
      desired_size   = 1
      min_size       = 0
      max_size       = 5
      labels         = { "workload" = "memory" }
    }
  }
}

module "eks_node_groups" {
  source   = "path/to/modules/eks-node-group"
  for_each = local.node_groups

  name         = each.key
  cluster_name = module.eks_cluster.name
  subnet_ids   = module.vpc.private_subnet_ids

  instance_types = each.value.instance_types
  desired_size   = each.value.desired_size
  min_size       = each.value.min_size
  max_size       = each.value.max_size
  labels         = each.value.labels

  tags = {
    Environment = "production"
  }
}
```

## Features

- **Managed Scaling**: AWS handles node provisioning and lifecycle
- **Spot Instances**: Cost-optimized capacity with interruption handling
- **Multiple Instance Types**: Flexibility for diverse workloads
- **ARM64/Graviton**: Cost-effective ARM-based nodes
- **GPU Support**: NVIDIA GPU instances for ML workloads
- **Bottlerocket**: Minimal, secure container OS
- **Taints & Labels**: Kubernetes scheduling controls

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Node group name | `string` | n/a | yes |
| cluster_name | EKS cluster name | `string` | n/a | yes |
| subnet_ids | Subnet IDs | `list(string)` | n/a | yes |
| desired_size | Desired node count | `number` | `2` | no |
| min_size | Minimum node count | `number` | `1` | no |
| max_size | Maximum node count | `number` | `5` | no |
| max_unavailable | Max unavailable during update | `number` | `1` | no |
| instance_types | Instance types | `list(string)` | `["t3.medium"]` | no |
| capacity_type | ON_DEMAND or SPOT | `string` | `"ON_DEMAND"` | no |
| disk_size | Disk size in GiB | `number` | `20` | no |
| ami_type | AMI type | `string` | `"AL2_x86_64"` | no |
| create_node_role | Create node IAM role | `bool` | `true` | no |
| node_role_policies | Additional IAM policies | `map(string)` | `{}` | no |
| remote_access | SSH access config | `object` | `null` | no |
| labels | Kubernetes labels | `map(string)` | `{}` | no |
| taints | Kubernetes taints | `list(object)` | `[]` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Node group ID |
| arn | Node group ARN |
| status | Node group status |
| scaling_config | Scaling configuration |
| autoscaling_group_names | ASG names |
| node_role_arn | Node IAM role ARN |
| node_role_name | Node IAM role name |

## AMI Types

| AMI Type | Description |
|----------|-------------|
| AL2_x86_64 | Amazon Linux 2 (x86_64) |
| AL2_x86_64_GPU | Amazon Linux 2 with GPU support |
| AL2_ARM_64 | Amazon Linux 2 (ARM64/Graviton) |
| BOTTLEROCKET_x86_64 | Bottlerocket (x86_64) |
| BOTTLEROCKET_ARM_64 | Bottlerocket (ARM64) |

## Considerations

- Node group updates may cause pod disruptions
- Spot instances can be reclaimed with 2-minute notice
- GPU instances require nvidia device plugin
- Custom launch templates provide more flexibility
- Multiple instance types improve Spot availability
