# EKS Cluster Module

Creates an Amazon EKS cluster with IAM roles, OIDC provider, and managed add-ons.

## Usage

### Basic Cluster

```hcl
module "eks_cluster" {
  source = "path/to/modules/eks-cluster"

  name       = "my-cluster"
  subnet_ids = module.vpc.private_subnet_ids

  tags = {
    Environment = "production"
  }
}
```

### Cluster with Specific Version

```hcl
module "eks_cluster" {
  source = "path/to/modules/eks-cluster"

  name               = "my-cluster"
  subnet_ids         = module.vpc.private_subnet_ids
  kubernetes_version = "1.29"

  tags = {
    Environment = "production"
  }
}
```

### Private Cluster

```hcl
module "eks_cluster" {
  source = "path/to/modules/eks-cluster"

  name       = "private-cluster"
  subnet_ids = module.vpc.private_subnet_ids

  # Private only - no public endpoint
  endpoint_private_access = true
  endpoint_public_access  = false

  tags = {
    Environment = "production"
  }
}
```

### Cluster with Restricted Public Access

```hcl
module "eks_cluster" {
  source = "path/to/modules/eks-cluster"

  name       = "restricted-cluster"
  subnet_ids = module.vpc.private_subnet_ids

  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs = [
    "10.0.0.0/8",      # Internal networks
    "203.0.113.0/24",  # Office IP range
  ]

  tags = {
    Environment = "production"
  }
}
```

### Cluster with Encryption

```hcl
module "eks_cluster" {
  source = "path/to/modules/eks-cluster"

  name       = "encrypted-cluster"
  subnet_ids = module.vpc.private_subnet_ids

  encryption_config = {
    provider_key_arn = module.kms_key.arn
    resources        = ["secrets"]
  }

  tags = {
    Environment = "production"
  }
}
```

### Cluster with Custom Add-ons

```hcl
module "eks_cluster" {
  source = "path/to/modules/eks-cluster"

  name       = "my-cluster"
  subnet_ids = module.vpc.private_subnet_ids

  # Override default add-ons and add new ones
  cluster_addons = {
    vpc-cni = {
      addon_version            = "v1.16.0-eksbuild.1"
      service_account_role_arn = module.vpc_cni_irsa_role.arn
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
      })
    }
    coredns = {
      addon_version = "v1.11.1-eksbuild.4"
    }
    kube-proxy = {
      addon_version = "v1.29.0-eksbuild.1"
    }
    aws-ebs-csi-driver = {
      addon_version            = "v1.27.0-eksbuild.1"
      service_account_role_arn = module.ebs_csi_irsa_role.arn
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Cluster with IAM Access Entries

```hcl
module "eks_cluster" {
  source = "path/to/modules/eks-cluster"

  name       = "my-cluster"
  subnet_ids = module.vpc.private_subnet_ids

  authentication_mode = "API"

  access_entries = {
    admins = {
      principal_arn = "arn:aws:iam::123456789012:role/AdminRole"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    developers = {
      principal_arn = "arn:aws:iam::123456789012:role/DeveloperRole"
      policy_associations = {
        view = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            type       = "namespace"
            namespaces = ["default", "app"]
          }
        }
      }
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Cluster without Default Add-ons

```hcl
module "eks_cluster" {
  source = "path/to/modules/eks-cluster"

  name       = "minimal-cluster"
  subnet_ids = module.vpc.private_subnet_ids

  # Don't install default add-ons (manage separately)
  enable_default_addons = false

  tags = {
    Environment = "production"
  }
}
```

### Cluster with Custom Logging

```hcl
module "eks_cluster" {
  source = "path/to/modules/eks-cluster"

  name       = "logged-cluster"
  subnet_ids = module.vpc.private_subnet_ids

  # Only enable specific log types
  enabled_cluster_log_types = ["api", "audit"]
  cluster_log_retention_days = 90

  tags = {
    Environment = "production"
  }
}
```

### Using IRSA (IAM Roles for Service Accounts)

```hcl
module "eks_cluster" {
  source = "path/to/modules/eks-cluster"

  name        = "irsa-cluster"
  subnet_ids  = module.vpc.private_subnet_ids
  enable_irsa = true

  tags = {
    Environment = "production"
  }
}

# Create IRSA role for an application
resource "aws_iam_role" "app" {
  name = "app-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks_cluster.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks_cluster.oidc_issuer_url}:sub" = "system:serviceaccount:default:my-app"
            "${module.eks_cluster.oidc_issuer_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}
```

## Features

- **Managed Control Plane**: Fully managed Kubernetes control plane
- **IAM Integration**: Automatic cluster IAM role creation
- **OIDC/IRSA**: IAM Roles for Service Accounts support
- **Add-ons**: Managed add-ons (vpc-cni, coredns, kube-proxy, etc.)
- **Access Management**: API-based access entries for IAM principals
- **Encryption**: KMS encryption for Kubernetes secrets
- **Logging**: CloudWatch logging for control plane components

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |
| tls | >= 4.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Cluster name | `string` | n/a | yes |
| subnet_ids | Subnet IDs (min 2 AZs) | `list(string)` | n/a | yes |
| kubernetes_version | Kubernetes version | `string` | `null` | no |
| enabled_cluster_log_types | Control plane log types | `list(string)` | `["api", "audit", ...]` | no |
| cluster_log_retention_days | Log retention days | `number` | `30` | no |
| endpoint_private_access | Enable private endpoint | `bool` | `true` | no |
| endpoint_public_access | Enable public endpoint | `bool` | `true` | no |
| public_access_cidrs | Public endpoint CIDRs | `list(string)` | `["0.0.0.0/0"]` | no |
| security_group_ids | Additional security groups | `list(string)` | `[]` | no |
| service_ipv4_cidr | Service IP CIDR | `string` | `null` | no |
| create_cluster_role | Create cluster IAM role | `bool` | `true` | no |
| encryption_config | Encryption configuration | `object` | `null` | no |
| cluster_addons | Add-ons to install | `map(object)` | `{}` | no |
| enable_default_addons | Enable default add-ons | `bool` | `true` | no |
| authentication_mode | Auth mode | `string` | `"API_AND_CONFIG_MAP"` | no |
| access_entries | IAM access entries | `map(object)` | `{}` | no |
| enable_irsa | Enable OIDC for IRSA | `bool` | `true` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Cluster ID |
| arn | Cluster ARN |
| name | Cluster name |
| endpoint | API server endpoint |
| certificate_authority_data | CA certificate data |
| version | Kubernetes version |
| platform_version | EKS platform version |
| cluster_security_group_id | Cluster security group ID |
| cluster_role_arn | Cluster IAM role ARN |
| oidc_issuer | OIDC issuer URL |
| oidc_issuer_url | OIDC issuer (no protocol) |
| oidc_provider_arn | OIDC provider ARN |
| addon_versions | Installed add-on versions |

## Update Kubeconfig

After cluster creation:

```bash
aws eks update-kubeconfig --name my-cluster --region us-east-1
```

## Considerations

- Cluster creation takes 10-15 minutes
- At least 2 subnets in different AZs required
- Private endpoint requires VPC connectivity for kubectl
- IRSA requires OIDC provider (enabled by default)
- Add-on updates may cause brief service disruption
