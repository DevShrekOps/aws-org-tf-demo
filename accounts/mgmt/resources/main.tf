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
}

resource "aws_identitystore_group" "org_admins" {
  display_name = "org-admins-${var.stage}"
  description  = "Grants full admin access to all accounts in the ${var.stage} org"

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

# Fetch the account ID & partition of the current AWS account
data "aws_caller_identity" "main" {}
data "aws_partition" "main" {}

# Store as local values for easier referencing
locals {
  account_id = data.aws_caller_identity.main.account_id
  partition  = data.aws_partition.main.partition
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
