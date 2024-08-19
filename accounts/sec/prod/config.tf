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

# Declare AWS providers for each enabled region of the prod security account.
# Unfortunately, as of Terraform v1.7, it's not possible to use `for_each` in a provider
# block. Thus, a separate provider block is declared for each region, resulting in a lot
# of duplication. This problem might be alleviated in the future with the release of
# Terraform Stacks.

provider "aws" {
  alias  = "ap_northeast_1"
  region = "ap-northeast-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "ap_northeast_2"
  region = "ap-northeast-2"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "ap_northeast_3"
  region = "ap-northeast-3"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "ap_south_1"
  region = "ap-south-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "ap_southeast_1"
  region = "ap-southeast-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "ap_southeast_2"
  region = "ap-southeast-2"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "ca_central_1"
  region = "ca-central-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "eu_central_1"
  region = "eu-central-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "eu_north_1"
  region = "eu-north-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "eu_west_1"
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "eu_west_2"
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "eu_west_3"
  region = "eu-west-3"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sa_east_1"
  region = "sa-east-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "us_east_2"
  region = "us-east-2"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "us_west_1"
  region = "us-west-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
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
