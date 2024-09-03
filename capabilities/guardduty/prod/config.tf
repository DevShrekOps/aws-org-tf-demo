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
    key            = "guardduty-prod"
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
    "devshrekops:demo:tf-config-path" = "capabilities/guardduty/prod"
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

# us-west-2

provider "aws" {
  alias  = "mgmt_us_west_2"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias  = "sec_us_west_2"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }

  default_tags {
    tags = local.default_tags
  }
}
