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
    key            = "org-dev"
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

provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev" # mgmt-dev
  }
}

## -------------------------------------------------------------------------------------
## IMPORTS
## -------------------------------------------------------------------------------------

# The mgmt account & org were manually created via the AWS console, declared in
# mgmt-resources, and imported in mgmt-dev before being removed from mgmt-dev, declared
# in org-resources, and imported here as part of refactoring the org into a standalone
# capability. Same as the sec account except it was created in mgmt-resources (not via
# the AWS console).
import {
  to = module.org_resources.aws_organizations_organization.main
  id = "o-pca28idqmq"
}
import {
  to = module.org_resources.aws_organizations_account.main["mgmt"]
  id = "533266992459"
}
import {
  to = module.org_resources.aws_organizations_account.main["sec"]
  id = "891377308296"
}
