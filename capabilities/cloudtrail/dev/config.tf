# See README.md in this repo's root directory for commentary on this file.

## -------------------------------------------------------------------------------------
## VERSIONS
## -------------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
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
    bucket         = "devshrekops-demo-tf-state-dev"
    key            = "cloudtrail-dev"
    dynamodb_table = "tf-state-locks-dev"
    region         = "us-east-1"
    assume_role = {
      role_arn = "arn:aws:iam::533266992459:role/tf-state-manager-dev"
    }
  }
}

## -------------------------------------------------------------------------------------
## PROVIDERS
## -------------------------------------------------------------------------------------

# us-east-1

provider "aws" {
  alias  = "mgmt_us_east_1"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_us_east_1"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

## -------------------------------------------------------------------------------------
## IMPORTS
## -------------------------------------------------------------------------------------

# Import resources created by mgmt-dev before refactoring CloudTrail into a capability
import {
  to = module.cloudtrail_resources.aws_iam_service_linked_role.main
  id = "arn:aws:iam::533266992459:role/aws-service-role/cloudtrail.amazonaws.com/AWSServiceRoleForCloudTrail"
}
import {
  to = module.cloudtrail_resources.aws_organizations_delegated_administrator.main
  id = "891377308296/cloudtrail.amazonaws.com"
}
import {
  to = module.cloudtrail_resources.module.baseline_s3_bucket.aws_s3_bucket.main
  id = "devshrekops-demo-cloudtrail-logs-dev"
}
import {
  to = module.cloudtrail_resources.module.baseline_s3_bucket.aws_s3_bucket_policy.main
  id = "devshrekops-demo-cloudtrail-logs-dev"
}
import {
  to = module.cloudtrail_resources.module.baseline_s3_bucket.aws_s3_bucket_ownership_controls.main
  id = "devshrekops-demo-cloudtrail-logs-dev"
}
import {
  to = module.cloudtrail_resources.module.baseline_s3_bucket.aws_s3_bucket_public_access_block.main
  id = "devshrekops-demo-cloudtrail-logs-dev"
}
import {
  to = module.cloudtrail_resources.aws_s3_bucket_lifecycle_configuration.main
  id = "devshrekops-demo-cloudtrail-logs-dev"
}
import {
  to = module.cloudtrail_resources.aws_cloudtrail.main
  id = "arn:aws:cloudtrail:us-east-1:533266992459:trail/main-dev"
}
