# See README.md in this repo's root directory for commentary on this file.

## -------------------------------------------------------------------------------------
## VERSIONS
## -------------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.39"
    }
  }

  required_version = "~> 1.7.0"
}

## -------------------------------------------------------------------------------------
## BACKEND
## -------------------------------------------------------------------------------------

# Since the bucket, table, & role referenced below are all declared in this root module,
# those resources must be deployed before adding this backend config. That means the
# state for those resources must temporarily be stored in a local `terraform.tfstate`
# file, but after adding this backend config and re-initializing Terraform, the local
# state will be migrated to the bucket.
terraform {
  backend "s3" {
    bucket         = "devshrekops-demo-tf-state-prod"
    key            = "tf-state-backend-prod"
    dynamodb_table = "tf-state-locks-prod"
    region         = "us-east-1"
    assume_role = {
      role_arn = "arn:aws:iam::339712815005:role/tf-state-manager-prod"
    }
  }
}

## -------------------------------------------------------------------------------------
## PROVIDERS
## -------------------------------------------------------------------------------------

provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod" # mgmt-prod
  }
}

## -------------------------------------------------------------------------------------
## IMPORTS
## -------------------------------------------------------------------------------------

# Import resources created by mgmt-dev before refactoring Terraform state backend into a
# capability.
import {
  to = module.tf_state_backend_resources.module.state_baseline_s3_bucket.aws_s3_bucket.main
  id = "devshrekops-demo-tf-state-prod"
}
import {
  to = module.tf_state_backend_resources.module.state_baseline_s3_bucket.aws_s3_bucket_policy.main
  id = "devshrekops-demo-tf-state-prod"
}
import {
  to = module.tf_state_backend_resources.module.state_baseline_s3_bucket.aws_s3_bucket_ownership_controls.main
  id = "devshrekops-demo-tf-state-prod"
}
import {
  to = module.tf_state_backend_resources.module.state_baseline_s3_bucket.aws_s3_bucket_public_access_block.main
  id = "devshrekops-demo-tf-state-prod"
}
import {
  to = module.tf_state_backend_resources.aws_s3_bucket_versioning.state
  id = "devshrekops-demo-tf-state-prod"
}
import {
  to = module.tf_state_backend_resources.aws_dynamodb_table.state_locks
  id = "tf-state-locks-prod"
}
import {
  to = module.tf_state_backend_resources.aws_iam_role.state_manager
  id = "tf-state-manager-prod"
}
