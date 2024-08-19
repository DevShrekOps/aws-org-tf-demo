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
    bucket         = "devshrekops-demo-tf-state-dev"
    key            = "sso-dev"
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

# These SSO resources were manually created via the AWS console, declared in
# mgmt-resources, and imported in mgmt-dev before being removed from mgmt-dev, declared
# in sso-resources, and imported here as part of refactoring SSO into a standalone
# capability.

# Import the org-admins-dev SSO group
import {
  to = module.sso_resources.aws_identitystore_group.org_admins
  id = "d-9067f854db/94784418-7091-7068-2428-0b327809cf24"
}

# Import the full-admin-access-dev SSO permission set
import {
  to = module.sso_resources.aws_ssoadmin_permission_set.full_admin
  id = join(",", [
    "arn:aws:sso:::permissionSet/ssoins-722327f2538a7b72/ps-8ba4e82e9024cb37",
    "arn:aws:sso:::instance/ssoins-722327f2538a7b72",
  ])
}

# Import the attachment of the AWS-managed AdministratorAccess IAM policy to the
# full-admin-access-dev SSO permission set.
import {
  to = module.sso_resources.aws_ssoadmin_managed_policy_attachment.full_admin
  id = join(",", [
    "arn:aws:iam::aws:policy/AdministratorAccess",
    "arn:aws:sso:::permissionSet/ssoins-722327f2538a7b72/ps-8ba4e82e9024cb37",
    "arn:aws:sso:::instance/ssoins-722327f2538a7b72",
  ])
}

# Import the assignment of the org-admins-dev SSO group with the full-admin-access-dev
# SSO permission set to the mgmt-dev account.
import {
  to = module.sso_resources.aws_ssoadmin_account_assignment.org_admins_full_admin["mgmt"]
  id = join(",", [
    "94784418-7091-7068-2428-0b327809cf24",
    "GROUP",
    "533266992459",
    "AWS_ACCOUNT",
    "arn:aws:sso:::permissionSet/ssoins-722327f2538a7b72/ps-8ba4e82e9024cb37",
    "arn:aws:sso:::instance/ssoins-722327f2538a7b72",
  ])
}

# Import the assignment of the org-admins-dev SSO group with the full-admin-access-dev
# SSO permission set to the sec-dev account.
import {
  to = module.sso_resources.aws_ssoadmin_account_assignment.org_admins_full_admin["sec"]
  id = join(",", [
    "94784418-7091-7068-2428-0b327809cf24",
    "GROUP",
    "891377308296",
    "AWS_ACCOUNT",
    "arn:aws:sso:::permissionSet/ssoins-722327f2538a7b72/ps-8ba4e82e9024cb37",
    "arn:aws:sso:::instance/ssoins-722327f2538a7b72",
  ])
}

# Import the donkey SSO user
import {
  to = module.sso_resources.aws_identitystore_user.main["donkey"]
  id = "d-9067f854db/440804d8-c0f1-7055-31c6-50afd56932a4"
}

# Import the group membership of the donkey SSO user in the org-admins-dev SSO group
import {
  to = module.sso_resources.aws_identitystore_group_membership.org_admins["donkey"]
  id = "d-9067f854db/5488c4d8-7011-70dc-1413-cbcf970d2cdd"
}

