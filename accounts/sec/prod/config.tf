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
    key            = "sec-prod"
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
    "devshrekops:demo:tf-config-path" = "accounts/sec/prod"
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }

  default_tags {
    tags = local.default_tags
  }
}

## -------------------------------------------------------------------------------------
## REMOVED
## -------------------------------------------------------------------------------------

# Removed when refactoring CloudTrail into a standalone capability.
removed {
  from = module.sec_resources.module.log_baseline_s3_bucket

  lifecycle {
    destroy = false
  }
}
removed {
  from = module.sec_resources.aws_s3_bucket_lifecycle_configuration.log

  lifecycle {
    destroy = false
  }
}
removed {
  from = module.sec_resources.aws_cloudtrail.main

  lifecycle {
    destroy = false
  }
}
