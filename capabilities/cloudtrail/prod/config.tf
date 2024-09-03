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

terraform {
  backend "s3" {
    bucket         = "devshrekops-demo-tf-state-prod"
    key            = "cloudtrail-prod"
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

locals {
  default_tags = {
    "devshrekops:demo:stage"          = "prod"
    "devshrekops:demo:tf-config-repo" = "aws-org-tf-demo"
    "devshrekops:demo:tf-config-path" = "capabilities/cloudtrail/prod"
  }
}

# us-east-1

provider "aws" {
  alias  = "mgmt_us_east_1"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias  = "sec_us_east_1"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }

  default_tags {
    tags = local.default_tags
  }
}

## -------------------------------------------------------------------------------------
## IMPORTS
## -------------------------------------------------------------------------------------

# Import resources created by mgmt-prod before refactoring CloudTrail into a capability
import {
  to = module.cloudtrail_resources.aws_iam_service_linked_role.main
  id = "arn:aws:iam::339712815005:role/aws-service-role/cloudtrail.amazonaws.com/AWSServiceRoleForCloudTrail"
}
import {
  to = module.cloudtrail_resources.aws_organizations_delegated_administrator.main
  id = "590183735431/cloudtrail.amazonaws.com"
}
import {
  to = module.cloudtrail_resources.module.baseline_s3_bucket.aws_s3_bucket.main
  id = "devshrekops-demo-cloudtrail-logs-prod"
}
import {
  to = module.cloudtrail_resources.module.baseline_s3_bucket.aws_s3_bucket_policy.main
  id = "devshrekops-demo-cloudtrail-logs-prod"
}
import {
  to = module.cloudtrail_resources.module.baseline_s3_bucket.aws_s3_bucket_ownership_controls.main
  id = "devshrekops-demo-cloudtrail-logs-prod"
}
import {
  to = module.cloudtrail_resources.module.baseline_s3_bucket.aws_s3_bucket_public_access_block.main
  id = "devshrekops-demo-cloudtrail-logs-prod"
}
import {
  to = module.cloudtrail_resources.aws_s3_bucket_lifecycle_configuration.main
  id = "devshrekops-demo-cloudtrail-logs-prod"
}
import {
  to = module.cloudtrail_resources.aws_cloudtrail.main
  id = "arn:aws:cloudtrail:us-east-1:339712815005:trail/main-prod"
}
