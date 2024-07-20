## -------------------------------------------------------------------------------------
## COMMON DATA SOURCES & LOCAL VALUES
## -------------------------------------------------------------------------------------

# Fetch the account ID of the management AWS account
data "aws_caller_identity" "mgmt" {}

# Store as local value for easier referencing
locals {
  mgmt_account_id = data.aws_caller_identity.mgmt.account_id
}

## -------------------------------------------------------------------------------------
## STATE S3 BUCKET
## -------------------------------------------------------------------------------------

# S3 bucket for storing state files for all the stage's Terraform configs
module "state_baseline_s3_bucket" {
  # This module declares an S3 bucket with a baseline configuration that should be used
  # for all buckets in this git repo unless there's a specific reason not to.
  source = "../../../modules/baseline-s3-bucket"

  stage = var.stage
  scope = "tf-state"
}

# Versioning makes it easier to recover deleted or corrupted state files
resource "aws_s3_bucket_versioning" "state" {
  bucket = module.state_baseline_s3_bucket.bucket_id

  versioning_configuration {
    status = "Enabled"
  }
}

## -------------------------------------------------------------------------------------
## STATE LOCKS DYNAMODB TABLE
## -------------------------------------------------------------------------------------

# Table for managing state locks for all the stage's Terraform configs. In the future,
# it might make sense to encrypt files in this table with a customer managed KMS key for
# enhanced access control & logging (or just to check a compliance box). But for now
# relying on the default SSE-S3 encryption is the simplest & cheapest approach.
resource "aws_dynamodb_table" "state_locks" {
  name = "tf-state-locks-${var.stage}"

  hash_key     = "LockID"          # Required per Terraform docs for state locks
  billing_mode = "PAY_PER_REQUEST" # Should be within free tier for this demo

  # Required per Terraform docs for state locks
  attribute {
    name = "LockID"
    type = "S"
  }
}

## -------------------------------------------------------------------------------------
## STATE MANAGER IAM ROLE
## -------------------------------------------------------------------------------------

# Role for managing state. Technically the deployer role could be used instead (or even
# the developer's SSO user or future pipeline's role). I'm not sure how much (if any)
# value there is in using a separate role for state management, but for some reason it
# feels cleaner despite the extra code, so I'm going with it for this demo.
resource "aws_iam_role" "state_manager" {
  name = "tf-state-manager-${var.stage}"

  # Allow same-account, sufficiently-privileged principals to assume this role
  assume_role_policy = data.aws_iam_policy_document.state_manager_trust.json

  # Allow this role to read from & write to the stage's state bucket & table
  inline_policy {
    name   = "manage-tf-state"
    policy = data.aws_iam_policy_document.state_manager_inline.json
  }
}

data "aws_iam_policy_document" "state_manager_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.mgmt_account_id}:root"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "state_manager_inline" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.state_baseline_s3_bucket.bucket_arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${module.state_baseline_s3_bucket.bucket_arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = [aws_dynamodb_table.state_locks.arn]
  }
}
