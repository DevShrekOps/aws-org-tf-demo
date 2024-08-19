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

# Declare AWS providers for each enabled region of the prod management & security
# accounts. Unfortunately, as of Terraform v1.7, it's not possible to use `for_each` in
# a provider block. Thus, a separate provider block is declared for each region of each
# account, resulting in a lot of duplication. This problem might be alleviated in the
# future with the release of Terraform Stacks.

# ap-northeast-1

provider "aws" {
  alias  = "mgmt_ap_northeast_1"
  region = "ap-northeast-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_ap_northeast_1"
  region = "ap-northeast-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

# ap-northeast-2

provider "aws" {
  alias  = "mgmt_ap_northeast_2"
  region = "ap-northeast-2"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_ap_northeast_2"
  region = "ap-northeast-2"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

# ap-northeast-3

provider "aws" {
  alias  = "mgmt_ap_northeast_3"
  region = "ap-northeast-3"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_ap_northeast_3"
  region = "ap-northeast-3"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

# ap-south-1

provider "aws" {
  alias  = "mgmt_ap_south_1"
  region = "ap-south-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_ap_south_1"
  region = "ap-south-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

# ap-southeast-1

provider "aws" {
  alias  = "mgmt_ap_southeast_1"
  region = "ap-southeast-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_ap_southeast_1"
  region = "ap-southeast-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

# ap-southeast-2

provider "aws" {
  alias  = "mgmt_ap_southeast_2"
  region = "ap-southeast-2"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_ap_southeast_2"
  region = "ap-southeast-2"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

# ca-central-1

provider "aws" {
  alias  = "mgmt_ca_central_1"
  region = "ca-central-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_ca_central_1"
  region = "ca-central-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

# eu-central-1

provider "aws" {
  alias  = "mgmt_eu_central_1"
  region = "eu-central-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_eu_central_1"
  region = "eu-central-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

# eu-north-1

provider "aws" {
  alias  = "mgmt_eu_north_1"
  region = "eu-north-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_eu_north_1"
  region = "eu-north-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

# eu-west-1

provider "aws" {
  alias  = "mgmt_eu_west_1"
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_eu_west_1"
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

# eu-west-2

provider "aws" {
  alias  = "mgmt_eu_west_2"
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_eu_west_2"
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

# eu-west-3

provider "aws" {
  alias  = "mgmt_eu_west_3"
  region = "eu-west-3"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_eu_west_3"
  region = "eu-west-3"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

# sa-east-1

provider "aws" {
  alias  = "mgmt_sa_east_1"
  region = "sa-east-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_sa_east_1"
  region = "sa-east-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

# us-east-1

provider "aws" {
  alias  = "mgmt_us_east_1"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_us_east_1"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

# us-east-2

provider "aws" {
  alias  = "mgmt_us_east_2"
  region = "us-east-2"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_us_east_2"
  region = "us-east-2"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

# us-west-1

provider "aws" {
  alias  = "mgmt_us_west_1"
  region = "us-west-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_us_west_1"
  region = "us-west-1"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}

# us-west-2

provider "aws" {
  alias  = "mgmt_us_west_2"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sec_us_west_2"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::590183735431:role/tf-deployer-prod"
  }
}
