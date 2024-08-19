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
    key            = "mgmt-prod"
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

# Declare AWS providers for each enabled region of the prod management account.
# Unfortunately, as of Terraform v1.7, it's not possible to use `for_each` in a provider
# block. Thus, a separate provider block is declared for each region, resulting in a lot
# of duplication. This problem might be alleviated in the future with the release of
# Terraform Stacks.

provider "aws" {
  alias  = "ap_northeast_1"
  region = "ap-northeast-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "ap_northeast_2"
  region = "ap-northeast-2"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "ap_northeast_3"
  region = "ap-northeast-3"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "ap_south_1"
  region = "ap-south-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "ap_southeast_1"
  region = "ap-southeast-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "ap_southeast_2"
  region = "ap-southeast-2"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "ca_central_1"
  region = "ca-central-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "eu_central_1"
  region = "eu-central-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "eu_north_1"
  region = "eu-north-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "eu_west_1"
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "eu_west_2"
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "eu_west_3"
  region = "eu-west-3"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "sa_east_1"
  region = "sa-east-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "us_east_2"
  region = "us-east-2"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "us_west_1"
  region = "us-west-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }
}

## -------------------------------------------------------------------------------------
## IMPORTS & REMOVED
## -------------------------------------------------------------------------------------

# Removed when refactoring CloudTrail into a standalone capability
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

# Removed when refactoring Terraform state backend into a standalone capability
removed {
  from = module.mgmt_resources.aws_dynamodb_table.tf_state_locks

  lifecycle {
    destroy = false
  }
}
removed {
  from = module.mgmt_resources.aws_iam_role.tf_state_manager

  lifecycle {
    destroy = false
  }
}
removed {
  from = module.mgmt_resources.aws_s3_bucket_versioning.tf_state

  lifecycle {
    destroy = false
  }
}
removed {
  from = module.mgmt_resources.module.tf_state_baseline_s3_bucket.aws_s3_bucket.main

  lifecycle {
    destroy = false
  }
}
removed {
  from = module.mgmt_resources.module.tf_state_baseline_s3_bucket.aws_s3_bucket_ownership_controls.main

  lifecycle {
    destroy = false
  }
}
removed {
  from = module.mgmt_resources.module.tf_state_baseline_s3_bucket.aws_s3_bucket_policy.main

  lifecycle {
    destroy = false
  }
}
removed {
  from = module.mgmt_resources.module.tf_state_baseline_s3_bucket.aws_s3_bucket_public_access_block.main

  lifecycle {
    destroy = false
  }
}

# Removed when refactoring the org into a standalone capability
removed {
  from = module.mgmt_resources.aws_organizations_organization.main

  lifecycle {
    destroy = false
  }
}
removed {
  from = module.mgmt_resources.aws_organizations_account.main

  lifecycle {
    destroy = false
  }
}

# Removed when refactoring IAM Identity Center (SSO) into a standalone capability
removed {
  from = module.mgmt_resources.aws_identitystore_group.org_admins

  lifecycle {
    destroy = false
  }
}
removed {
  from = module.mgmt_resources.aws_identitystore_group_membership.org_admins

  lifecycle {
    destroy = false
  }
}
removed {
  from = module.mgmt_resources.aws_identitystore_user.main

  lifecycle {
    destroy = false
  }
}
removed {
  from = module.mgmt_resources.aws_ssoadmin_account_assignment.org_admins_full_admin

  lifecycle {
    destroy = false
  }
}
removed {
  from = module.mgmt_resources.aws_ssoadmin_managed_policy_attachment.full_admin

  lifecycle {
    destroy = false
  }
}
removed {
  from = module.mgmt_resources.aws_ssoadmin_permission_set.full_admin

  lifecycle {
    destroy = false
  }
}

# Import cost anomaly detection resources that were automatically created when
# navigating to the billing dashboard in the AWS console for the first time.
import {
  to = module.mgmt_resources.aws_ce_anomaly_monitor.main
  id = "arn:aws:ce::339712815005:anomalymonitor/a867bd1b-3110-4c5b-a7e0-479d690e6a8c"
}
import {
  to = module.mgmt_resources.aws_ce_anomaly_subscription.main
  id = "arn:aws:ce::339712815005:anomalysubscription/760fdb4a-9b87-418b-939c-ae4df60de48c"
}
