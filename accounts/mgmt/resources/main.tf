## -------------------------------------------------------------------------------------
## COMMON DATA SOURCES & LOCAL VALUES
## -------------------------------------------------------------------------------------

# Fetch the account ID & partition of the current AWS account
data "aws_caller_identity" "main" {}
data "aws_partition" "main" {}

# Store as local values for easier referencing
locals {
  account_id = data.aws_caller_identity.main.account_id
  partition  = data.aws_partition.main.partition
}

## -------------------------------------------------------------------------------------
## ORGANIZATION
## -------------------------------------------------------------------------------------

# Declare an org resource so that manually-created orgs can be imported into and managed
# by Terraform as additional service integrations & policy types are enabled over time.
resource "aws_organizations_organization" "main" {
  # Required for key features (e.g., integration with IAM Identity Center)
  feature_set = "ALL"

  # Integrate the org with other services (e.g., IAM Identity Center)
  aws_service_access_principals = [
    "sso.amazonaws.com", # IAM Identity Center
  ]
}

resource "aws_organizations_account" "main" {
  # The for_each uses account key as the key (as opposed to a numeric index) for more
  # expressive plans & state files and so that if an account is removed from the list it
  # doesn't impact other accounts.
  for_each = toset(var.account_keys)

  name  = "demo-${each.key}-${var.stage}"
  email = "devshrekops+demo-${each.key}-${var.stage}@gmail.com"

  # An OU structure will be created in the future, but for now all accounts will go into
  # the root of the org. This is the default behavior, but explicitly setting it anyway
  # so that Terraform will perform drift detection on any manual changes to parent ID.
  parent_id = aws_organizations_organization.main.roots[0].id

  close_on_deletion          = true
  iam_user_access_to_billing = "ALLOW"

  role_name = "tf-deployer-${var.stage}"

  lifecycle {
    # Configure Terraform to ignore changes to the iam_user_access_to_billing attribute
    # so that Terraform doesn't plan to recreate management accounts when imported. Also
    # ignore changes to role_name per the Terraform docs: "The Organizations API
    # provides no method for reading this information after account creation, so
    # Terraform cannot perform drift detection on its value and will always show a
    # difference for a configured value after import unless ignore_changes is used."
    ignore_changes = [iam_user_access_to_billing, role_name]
  }
}

## -------------------------------------------------------------------------------------
## IAM IDENTITY CENTER (SSO)
## -------------------------------------------------------------------------------------

# At this time, the Terraform AWS provider only provides a data source (not a resource)
# for IAM Identity Center instances. The data source doesn't allow the manually-created
# instance to be imported into and managed by Terraform, but at least it provides access
# to its attributes.
data "aws_ssoadmin_instances" "main" {}

# Store as local values for easier referencing
locals {
  sso_instance_arn      = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  sso_identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
}

# The AWS-managed AdministratorAccess IAM policy that exists in every account.
data "aws_iam_policy" "full_admin" {
  name = "AdministratorAccess"
}

resource "aws_ssoadmin_permission_set" "full_admin" {
  name             = "full-admin-access-${var.stage}"
  description      = "Grants full admin access to a ${var.stage} account"
  session_duration = "PT12H" # 12 hours

  instance_arn = local.sso_instance_arn
}

resource "aws_ssoadmin_managed_policy_attachment" "full_admin" {
  managed_policy_arn = data.aws_iam_policy.full_admin.arn
  permission_set_arn = aws_ssoadmin_permission_set.full_admin.arn

  instance_arn = local.sso_instance_arn

  # The Terraform AWS provider docs state that an explicit dependency on account
  # assignments is necessary "to ensure proper deletion order" if this resource is
  # deleted "because destruction of a managed policy attachment resource also
  # re-provisions the associated permission set to all accounts."
  depends_on = [aws_ssoadmin_account_assignment.org_admins_full_admin]
}

resource "aws_identitystore_group" "org_admins" {
  display_name = "org-admins-${var.stage}"
  description  = "Grants full admin access to all accounts in the ${var.stage} org"

  identity_store_id = local.sso_identity_store_id
}

# Grant org admins full admin access to every account
resource "aws_ssoadmin_account_assignment" "org_admins_full_admin" {
  for_each = aws_organizations_account.main

  principal_type = "GROUP"
  principal_id   = aws_identitystore_group.org_admins.group_id

  permission_set_arn = aws_ssoadmin_permission_set.full_admin.arn

  target_type = "AWS_ACCOUNT"
  target_id   = each.value.id

  instance_arn = local.sso_instance_arn
}

resource "aws_identitystore_group_membership" "org_admins" {
  # The for_each uses username as the key (as opposed to a numeric index) for more
  # expressive plans & state files and so that if a user is removed from the list it
  # doesn't impact other users.
  for_each = toset(var.sso_org_admins)

  group_id  = aws_identitystore_group.org_admins.group_id
  member_id = aws_identitystore_user.main[each.key].user_id

  identity_store_id = local.sso_identity_store_id
}

resource "aws_identitystore_user" "main" {
  # Create a separate user for each element in var.sso_users. The for_each uses username
  # as the key (as opposed to a numeric index) for more expressive plans & state files
  # and so that if a user is removed from the list it doesn't impact other users.
  for_each = { for sso_user in var.sso_users : sso_user.username => sso_user }

  user_name    = each.key
  display_name = each.value.display_name

  emails {
    value   = each.value.email
    type    = "work"
    primary = true
  }

  name {
    given_name  = each.value.first_name
    family_name = each.value.last_name
  }

  identity_store_id = local.sso_identity_store_id
}

## -------------------------------------------------------------------------------------
## TERRAFORM STATE S3 BACKEND
## -------------------------------------------------------------------------------------

# Bucket for storing Terraform state files for all accounts belonging to this stage. In
# the future, it might make sense to encrypt files in this bucket with a customer
# managed KMS key for enhanced access control & logging (or just to check a compliance
# box). But for now relying on the default SSE-S3 encryption is the simplest & cheapest
# approach.
resource "aws_s3_bucket" "tf_state" {
  # Prefix with "devshrekops-" to reduce chance of naming collision with other customers
  # and include "demo-" to reduce chance of naming collision with other DevShrekOps
  # projects.
  bucket = "devshrekops-demo-tf-state-${var.stage}"
}

# Versioning makes it easier to recover deleted or corrupted state files
resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Disable ACLs because they're an unnecessary, legacy form of access control, instead
# relying on bucket policies and IAM to govern access to the bucket.
resource "aws_s3_bucket_ownership_controls" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Prevent a misconfiguration that could make the bucket publicly accessible. This
# probably isn't necessary since I plan on enabling this control at the account layer.
# At a minimum, it might check a compliance box.
resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Table for managing Terraform state locks for all accounts belonging to this stage. In
# the future, it might make sense to encrypt files in this table with a customer managed
# KMS key for enhanced access control & logging (or just to check a compliance box). But
# for now relying on the default SSE-S3 encryption is the simplest & cheapest approach.
resource "aws_dynamodb_table" "tf_state_locks" {
  name = "tf-state-locks-${var.stage}"

  hash_key     = "LockID"          # Required per Terraform docs for DynamoDB State Locking
  billing_mode = "PAY_PER_REQUEST" # Should be within free tier for this demo

  # Required per Terraform docs for DynamoDB State Locking
  attribute {
    name = "LockID"
    type = "S"
  }
}

# Role for managing state. Technically the deployer role could be used instead (or even
# the developer's SSO user or future pipeline's role). I'm not sure how much (if any)
# value there is in using a separate role for state management, but for some reason it
# feels cleaner despite the extra code, so I'm going with it for this demo.
resource "aws_iam_role" "tf_state_manager" {
  name = "tf-state-manager-${var.stage}"

  # Allow same-account, sufficiently-privileged principals to assume this role
  assume_role_policy = data.aws_iam_policy_document.tf_state_manager_trust.json

  # Allow this role to read from & write to the state bucket & table for this stage
  inline_policy {
    name   = "manage-tf-state"
    policy = data.aws_iam_policy_document.tf_state_manager_inline.json
  }
}

data "aws_iam_policy_document" "tf_state_manager_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "tf_state_manager_inline" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.tf_state.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.tf_state.arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = [aws_dynamodb_table.tf_state_locks.arn]
  }
}
