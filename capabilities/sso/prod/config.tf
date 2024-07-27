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
    key            = "sso-prod"
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
}

## -------------------------------------------------------------------------------------
## IMPORTS
## -------------------------------------------------------------------------------------

# These SSO resources were manually created via the AWS console, declared in
# mgmt-resources, and imported in mgmt-prod before being removed from mgmt-prod,
# declared in sso-resources, and imported here as part of refactoring SSO into a
# standalone capability.

# Import the org-admins-prod SSO group
import {
  to = module.sso_resources.aws_identitystore_group.org_admins
  id = "d-9067fc28a6/04183448-d091-70b1-7e76-5f2ebfdc549e"
}

# Import the full-admin-access-prod SSO permission set
import {
  to = module.sso_resources.aws_ssoadmin_permission_set.full_admin
  id = join(",", [
    "arn:aws:sso:::permissionSet/ssoins-72232a1562dbd133/ps-a095036f1fc365cf",
    "arn:aws:sso:::instance/ssoins-72232a1562dbd133",
  ])
}

# Import the attachment of the AWS-managed AdministratorAccess IAM policy to the
# full-admin-access-prod SSO permission set.
import {
  to = module.sso_resources.aws_ssoadmin_managed_policy_attachment.full_admin
  id = join(",", [
    "arn:aws:iam::aws:policy/AdministratorAccess",
    "arn:aws:sso:::permissionSet/ssoins-72232a1562dbd133/ps-a095036f1fc365cf",
    "arn:aws:sso:::instance/ssoins-72232a1562dbd133",
  ])
}

# Import the assignment of the org-admins-prod SSO group with the full-admin-access-prod
# SSO permission set to the mgmt-prod account.
import {
  to = module.sso_resources.aws_ssoadmin_account_assignment.org_admins_full_admin["mgmt"]
  id = join(",", [
    "04183448-d091-70b1-7e76-5f2ebfdc549e",
    "GROUP",
    "339712815005",
    "AWS_ACCOUNT",
    "arn:aws:sso:::permissionSet/ssoins-72232a1562dbd133/ps-a095036f1fc365cf",
    "arn:aws:sso:::instance/ssoins-72232a1562dbd133",
  ])
}

# Import the assignment of the org-admins-prod SSO group with the full-admin-access-prod
# SSO permission set to the sec-prod account.
import {
  to = module.sso_resources.aws_ssoadmin_account_assignment.org_admins_full_admin["sec"]
  id = join(",", [
    "04183448-d091-70b1-7e76-5f2ebfdc549e",
    "GROUP",
    "590183735431",
    "AWS_ACCOUNT",
    "arn:aws:sso:::permissionSet/ssoins-72232a1562dbd133/ps-a095036f1fc365cf",
    "arn:aws:sso:::instance/ssoins-72232a1562dbd133",
  ])
}

# Import the donkey SSO user
import {
  to = module.sso_resources.aws_identitystore_user.main["donkey"]
  id = "d-9067fc28a6/44e82448-10c1-70e3-27d3-d17c39986d90"
}

# Import the group membership of the donkey SSO user in the org-admins-prod SSO group
import {
  to = module.sso_resources.aws_identitystore_group_membership.org_admins["donkey"]
  id = "d-9067fc28a6/34a8f488-a031-70f6-6346-11ed3628c66b"
}
