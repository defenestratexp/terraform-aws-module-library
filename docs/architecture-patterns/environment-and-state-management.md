# Environment and State Management

## Environment Management Approaches

| Approach | Pros | Cons |
|----------|------|------|
| **Terraform Workspaces** | Simple, built-in, single codebase | Easy to accidentally apply to wrong env, shared state bucket |
| **Directory-based** | Clear separation, explicit configs | Code duplication between envs |
| **Terragrunt** | DRY configs, auto-generates backends, inheritance | Another tool, learning curve |
| **Branch-based** | - | Don't do this - drift, merge hell |

## State Management Options

### Option 1: Single bucket, keyed by environment
```
s3://client-tfstate/
├── dev/terraform.tfstate
├── staging/terraform.tfstate
└── prod/terraform.tfstate

dynamodb: client-tfstate-lock (shared)
```

### Option 2: Bucket per environment
```
s3://client-tfstate-dev/terraform.tfstate
s3://client-tfstate-staging/terraform.tfstate
s3://client-tfstate-prod/terraform.tfstate

dynamodb: one table per env (or shared)
```

### Option 3: Separate AWS accounts per environment (most secure)
```
AWS Account: client-dev     → s3://tfstate/...
AWS Account: client-staging → s3://tfstate/...
AWS Account: client-prod    → s3://tfstate/...
```

## Recommended Structure for Client Consulting

```
terraform-aws-module-library/      # Reusable modules repo
  └── aws/modules/...

client-deployments/                # Separate repo per client
  └── acme-corp/
      ├── _bootstrap/              # Creates state bucket + dynamo (run once manually)
      │   └── main.tf
      ├── environments/
      │   ├── dev/
      │   │   ├── backend.tf       # s3://acme-tfstate/dev/
      │   │   ├── main.tf          # Calls modules from this library
      │   │   └── variables.tf
      │   ├── staging/
      │   └── prod/
      └── README.md
```

### Backend Configuration Example (dev)
```hcl
terraform {
  backend "s3" {
    bucket         = "acme-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "acme-tfstate-lock"
    encrypt        = true
  }
}
```

### Bootstrap Module Usage
```hcl
# Creates: S3 bucket + DynamoDB table for a client
module "terraform_state" {
  source = "git::https://github.com/defenestratexp/terraform-aws-module-library.git//aws/modules/terraform-state"

  client = "acme"
  region = "us-west-2"
}
```

## Terragrunt Alternative (DRY configs)

```
acme-corp/
├── terragrunt.hcl              # Root: defines backend pattern
├── dev/
│   ├── terragrunt.hcl          # include root, set environment = "dev"
│   └── vpc/
│       └── terragrunt.hcl      # Calls VPC module
├── staging/
└── prod/
```

Root `terragrunt.hcl`:
```hcl
remote_state {
  backend = "s3"
  config = {
    bucket         = "acme-tfstate"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "acme-tfstate-lock"
    encrypt        = true
  }
}
```

---

## Decision Record

### Question 1: Pure Terraform or Terragrunt?
**Decision:** Pure Terraform with module composition pattern

**Rationale:** Fewer tools for clients to learn and support. Environments are thin wrappers that call modules - duplication is minimal (backend.tf, provider.tf, main.tf with module call). Terragrunt patterns can be added later for complex engagements with proper documentation.

### Question 2: Single AWS account per client or multi-account (dev/staging/prod)?
**Decision:** Flexible - client-dependent

**Rationale:** Account strategy depends on client situation:
- Client has existing AWS account → deploy into their account
- Client has no infrastructure → create and manage account for them (management fee)
- Enterprise clients → AWS Organizations / Control Tower option

Modules must be account-agnostic and work in any setup. State backend per client regardless of account model.

### Question 3: Build a bootstrap module for state infrastructure?
**Decision:** Yes - build bootstrap module

**Rationale:** Standardized state infrastructure setup run once per client. Based on an earlier in-house state bootstrap, modernized with:
- Current AWS provider syntax (no deprecated `acl`)
- Configurable client/project naming
- Optional versioning, replication, lifecycle policies
- PAY_PER_REQUEST for DynamoDB (no capacity planning)
- Standard tagging
