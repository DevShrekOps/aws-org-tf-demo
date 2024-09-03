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
    key            = "org-prod"
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

provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod" # mgmt-prod
  }

  default_tags {
    tags = {
      "devshrekops:demo:stage"          = "prod"
      "devshrekops:demo:tf-config-repo" = "aws-org-tf-demo"
      "devshrekops:demo:tf-config-path" = "capabilities/org/prod"
    }
  }
}

## -------------------------------------------------------------------------------------
## IMPORTS
## -------------------------------------------------------------------------------------

# The mgmt account & org were manually created via the AWS console, declared in
# mgmt-resources, and imported in mgmt-prod before being removed from mgmt-prod,
# declared in org-resources, and imported here as part of refactoring the org into a
# standalone capability. Same as the sec account except it was created in mgmt-resources
# (not via the AWS console).
import {
  to = module.org_resources.aws_organizations_organization.main
  id = "o-32fecjn1ln"
}
import {
  to = module.org_resources.aws_organizations_account.main["mgmt"]
  id = "339712815005"
}
import {
  to = module.org_resources.aws_organizations_account.main["sec"]
  id = "590183735431"
}
