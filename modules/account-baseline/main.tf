## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will be created in us-east-1 of every account
# in every stage, but not any other region.

## -------------------------------------------------------------------------------------
## ACCOUNT ALIAS
## -------------------------------------------------------------------------------------

# Prefix with "devshrekops-" to reduce chance of naming collision with other customers
# and include "demo-" to reduce chance of naming collision with other DevShrekOps
# projects.
resource "aws_iam_account_alias" "main" {
  account_alias = "devshrekops-demo-${var.account_key}-${var.stage}"
}

## -------------------------------------------------------------------------------------
## S3 ACCOUNT PUBLIC ACCESS BLOCK
## -------------------------------------------------------------------------------------

# Drastically reduce the chances of an S3 bucket being accidentally opened to the public
resource "aws_s3_account_public_access_block" "main" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
