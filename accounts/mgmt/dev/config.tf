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
    role_arn = "arn:aws:iam::533266992459:role/tf-deployer-dev"
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
    bucket         = "devshrekops-demo-tf-state-dev"
    key            = "mgmt-dev"
    dynamodb_table = "tf-state-locks-dev"
    region         = "us-east-1"
    assume_role = {
      role_arn = "arn:aws:iam::533266992459:role/tf-state-manager-dev"
    }
  }
}

## -------------------------------------------------------------------------------------
## IMPORTS, MOVED, & REMOVED
## -------------------------------------------------------------------------------------

# Import the org that was manually created in this account when IAM Identity Center was
# enabled.
import {
  to = module.mgmt_resources.aws_organizations_organization.main
  id = "o-pca28idqmq"
}

# Import the org-admins-dev SSO group that was manually created in this account.
import {
  to = module.mgmt_resources.aws_identitystore_group.org_admins
  id = "d-9067f854db/94784418-7091-7068-2428-0b327809cf24"
}

# Import the full-admin-access-dev SSO permission set that was manually created in this
# account.
import {
  to = module.mgmt_resources.aws_ssoadmin_permission_set.full_admin
  id = join(",", [
    "arn:aws:sso:::permissionSet/ssoins-722327f2538a7b72/ps-8ba4e82e9024cb37",
    "arn:aws:sso:::instance/ssoins-722327f2538a7b72",
  ])
}

# Import the attachment of the AWS-managed AdministratorAccess IAM policy to the
# full-admin-access-dev SSO permission set that was manually created in this account.
import {
  to = module.mgmt_resources.aws_ssoadmin_managed_policy_attachment.full_admin
  id = join(",", [
    "arn:aws:iam::aws:policy/AdministratorAccess",
    "arn:aws:sso:::permissionSet/ssoins-722327f2538a7b72/ps-8ba4e82e9024cb37",
    "arn:aws:sso:::instance/ssoins-722327f2538a7b72",
  ])
}

# Import the assignment of the org-admins-dev SSO group with the full-admin-access-dev
# SSO permission set to the mgmt-dev account that was manually created in this account.
import {
  to = module.mgmt_resources.aws_ssoadmin_account_assignment.org_admins_full_admin["mgmt"]
  id = join(",", [
    "94784418-7091-7068-2428-0b327809cf24",
    "GROUP",
    "533266992459",
    "AWS_ACCOUNT",
    "arn:aws:sso:::permissionSet/ssoins-722327f2538a7b72/ps-8ba4e82e9024cb37",
    "arn:aws:sso:::instance/ssoins-722327f2538a7b72",
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
  id = "d-9067f854db/440804d8-c0f1-7055-31c6-50afd56932a4"
}

# Import the group membership of the donkey SSO user in the org-admins-dev SSO group
# that was manually configured in this account.
import {
  to = module.mgmt_resources.aws_identitystore_group_membership.org_admins["donkey"]
  id = "d-9067f854db/5488c4d8-7011-70dc-1413-cbcf970d2cdd"
}

# Import the management account that was manually created via the AWS website.
import {
  to = module.mgmt_resources.aws_organizations_account.main["mgmt"]
  id = "533266992459"
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

# Removed when refactoring CloudTrail into a standalone capability.
removed {
  from = module.mgmt_resources.aws_organizations_delegated_administrator.cloudtrail_sec

  lifecycle {
    destroy = false
  }
}
removed {
  from = module.mgmt_resources.aws_iam_service_linked_role.cloudtrail

  lifecycle {
    destroy = false
  }
}
