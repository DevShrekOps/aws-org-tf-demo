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
## PROVIDERS
## -------------------------------------------------------------------------------------

provider "aws" {
  # Prevent accidental deployment into the wrong account
  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }

  # Prevent accidental deployment into the wrong region
  region = "us-east-1"
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
