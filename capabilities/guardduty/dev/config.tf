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
    key            = "guardduty-dev"
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

# ap-northeast-1

provider "aws" {
  alias  = "mgmt_ap_northeast_1"
  region = "ap-northeast-1"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_ap_northeast_1"
  region = "ap-northeast-1"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

# ap-northeast-2

provider "aws" {
  alias  = "mgmt_ap_northeast_2"
  region = "ap-northeast-2"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_ap_northeast_2"
  region = "ap-northeast-2"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

# ap-northeast-3

provider "aws" {
  alias  = "mgmt_ap_northeast_3"
  region = "ap-northeast-3"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_ap_northeast_3"
  region = "ap-northeast-3"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

# ap-south-1

provider "aws" {
  alias  = "mgmt_ap_south_1"
  region = "ap-south-1"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_ap_south_1"
  region = "ap-south-1"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

# ap-southeast-1

provider "aws" {
  alias  = "mgmt_ap_southeast_1"
  region = "ap-southeast-1"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_ap_southeast_1"
  region = "ap-southeast-1"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

# ap-southeast-2

provider "aws" {
  alias  = "mgmt_ap_southeast_2"
  region = "ap-southeast-2"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_ap_southeast_2"
  region = "ap-southeast-2"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

# ca-central-1

provider "aws" {
  alias  = "mgmt_ca_central_1"
  region = "ca-central-1"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_ca_central_1"
  region = "ca-central-1"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

# eu-central-1

provider "aws" {
  alias  = "mgmt_eu_central_1"
  region = "eu-central-1"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_eu_central_1"
  region = "eu-central-1"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

# eu-north-1

provider "aws" {
  alias  = "mgmt_eu_north_1"
  region = "eu-north-1"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_eu_north_1"
  region = "eu-north-1"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

# eu-west-1

provider "aws" {
  alias  = "mgmt_eu_west_1"
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_eu_west_1"
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

# eu-west-2

provider "aws" {
  alias  = "mgmt_eu_west_2"
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_eu_west_2"
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

# eu-west-3

provider "aws" {
  alias  = "mgmt_eu_west_3"
  region = "eu-west-3"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_eu_west_3"
  region = "eu-west-3"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

# sa-east-1

provider "aws" {
  alias  = "mgmt_sa_east_1"
  region = "sa-east-1"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_sa_east_1"
  region = "sa-east-1"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

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

# us-east-2

provider "aws" {
  alias  = "mgmt_us_east_2"
  region = "us-east-2"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_us_east_2"
  region = "us-east-2"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

# us-west-1

provider "aws" {
  alias  = "mgmt_us_west_1"
  region = "us-west-1"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_us_west_1"
  region = "us-west-1"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

# us-west-2

provider "aws" {
  alias  = "mgmt_us_west_2"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
  }
}

provider "aws" {
  alias  = "sec_us_west_2"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::891377308296:role/tf-deployer-dev"
  }
}

## -------------------------------------------------------------------------------------
## IMPORTS
## -------------------------------------------------------------------------------------

# Import service-linked role that was created automatically during development
import {
  to = module.guardduty_resources.aws_iam_service_linked_role.main
  id = "arn:aws:iam::590183735431:role/aws-service-role/guardduty.amazonaws.com/AWSServiceRoleForAmazonGuardDuty"
}
