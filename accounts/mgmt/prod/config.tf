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
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }

  # Prevent accidental deployment into the wrong region
  region = "us-east-1"
}

## -------------------------------------------------------------------------------------
## BACKEND
## -------------------------------------------------------------------------------------

# Since the bucket, table, & role referenced below are all declared in this root module,
# those resources had to be deployed before adding this backend config. That means the
# state for those resources was temporarily stored in a local `terraform.tfstate` file,
# but after adding this backend config and re-initializing Terraform, the local state
# was migrated to the bucket.
terraform {
  backend "s3" {
    bucket         = "devshrekops-demo-tf-state-prod"
    key            = "mgmt-prod"
    dynamodb_table = "tf-state-locks-prod"
    region         = "us-east-1"
    assume_role = {
      role_arn = "arn:aws:iam::339712815005:role/tf-state-manager-prod"
    }
  }
}

## -------------------------------------------------------------------------------------
## IMPORTS & MOVED
## -------------------------------------------------------------------------------------

# Import the org that was manually created in this account when IAM Identity Center was
# enabled.
import {
  to = module.mgmt_resources.aws_organizations_organization.main
  id = "o-32fecjn1ln"
}

# Import the org-admins-prod SSO group that was manually created in this account.
import {
  to = module.mgmt_resources.aws_identitystore_group.org_admins
  id = "d-9067fc28a6/04183448-d091-70b1-7e76-5f2ebfdc549e"
}

# Import the full-admin-access-prod SSO permission set that was manually created in this
# account.
import {
  to = module.mgmt_resources.aws_ssoadmin_permission_set.full_admin
  id = join(",", [
    "arn:aws:sso:::permissionSet/ssoins-72232a1562dbd133/ps-a095036f1fc365cf",
    "arn:aws:sso:::instance/ssoins-72232a1562dbd133",
  ])
}

# Import the attachment of the AWS-managed AdministratorAccess IAM policy to the
# full-admin-access-prod SSO permission set that was manually created in this account.
import {
  to = module.mgmt_resources.aws_ssoadmin_managed_policy_attachment.full_admin
  id = join(",", [
    "arn:aws:iam::aws:policy/AdministratorAccess",
    "arn:aws:sso:::permissionSet/ssoins-72232a1562dbd133/ps-a095036f1fc365cf",
    "arn:aws:sso:::instance/ssoins-72232a1562dbd133",
  ])
}

# Import the assignment of the org-admins-prod SSO group with the full-admin-access-prod
# SSO permission set to the mgmt-prod account that was manually created in this account.
import {
  to = module.mgmt_resources.aws_ssoadmin_account_assignment.org_admins_full_admin["mgmt"]
  id = join(",", [
    "04183448-d091-70b1-7e76-5f2ebfdc549e",
    "GROUP",
    "339712815005",
    "AWS_ACCOUNT",
    "arn:aws:sso:::permissionSet/ssoins-72232a1562dbd133/ps-a095036f1fc365cf",
    "arn:aws:sso:::instance/ssoins-72232a1562dbd133",
  ])
}

# Moved due to refactoring when granting org admins access to all accounts in the org.
moved {
  from = module.mgmt_resources.aws_ssoadmin_account_assignment.org_admins_full_admin_mgmt
  to   = module.mgmt_resources.aws_ssoadmin_account_assignment.org_admins_full_admin["mgmt"]
}

# Import the donkey SSO user that was manually created in this account.
import {
  to = module.mgmt_resources.aws_identitystore_user.main["donkey"]
  id = "d-9067fc28a6/44e82448-10c1-70e3-27d3-d17c39986d90"
}

# Import the group membership of the donkey SSO user in the org-admins-prod SSO group
# that was manually configured in this account.
import {
  to = module.mgmt_resources.aws_identitystore_group_membership.org_admins["donkey"]
  id = "d-9067fc28a6/34a8f488-a031-70f6-6346-11ed3628c66b"
}

# Import the management account that was manually created via the AWS website.
import {
  to = module.mgmt_resources.aws_organizations_account.main["mgmt"]
  id = "339712815005"
}

# Moved when refactoring to use the new baseline-s3-bucket module to create the S3
# bucket for storing Terraform state.
moved {
  from = module.mgmt_resources.aws_s3_bucket.tf_state
  to   = module.mgmt_resources.module.tf_state_baseline_s3_bucket.aws_s3_bucket.main
}
moved {
  from = module.mgmt_resources.aws_s3_bucket_ownership_controls.tf_state
  to   = module.mgmt_resources.module.tf_state_baseline_s3_bucket.aws_s3_bucket_ownership_controls.main
}
moved {
  from = module.mgmt_resources.aws_s3_bucket_public_access_block.tf_state
  to   = module.mgmt_resources.module.tf_state_baseline_s3_bucket.aws_s3_bucket_public_access_block.main
}
