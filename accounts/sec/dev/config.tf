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
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }

  # Prevent accidental deployment into the wrong region
  region = "us-east-1"
}

## -------------------------------------------------------------------------------------
## BACKEND
## -------------------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket         = "devshrekops-demo-tf-state-dev"
    key            = "sec-dev"
    dynamodb_table = "tf-state-locks-dev"
    region         = "us-east-1"
    assume_role = {
      role_arn = "arn:aws:iam::533266992459:role/tf-state-manager-dev"
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
