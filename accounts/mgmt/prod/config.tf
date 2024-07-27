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
## REMOVED
## -------------------------------------------------------------------------------------

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

# Removed when refactoring Terraform state backend into a standalone capability.
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
