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

locals {
  default_tags = {
    "devshrekops:demo:stage"          = "prod"
    "devshrekops:demo:tf-config-repo" = "aws-org-tf-demo"
    "devshrekops:demo:tf-config-path" = "accounts/mgmt/prod"
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }

  default_tags {
    tags = local.default_tags
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
