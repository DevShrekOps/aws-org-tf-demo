## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will only be created in us-east-1 of each
# stage's management or security account (depending on provider), not any other account
# nor region.

## -------------------------------------------------------------------------------------
## COMMON DATA SOURCES & LOCAL VALUES
## -------------------------------------------------------------------------------------

# Fetch the account ID of the security AWS account
data "aws_caller_identity" "sec" {
  provider = aws.sec_us_east_1
}

# Store as local value for easier referencing
locals {
  sec_account_id = data.aws_caller_identity.sec.account_id
}

## -------------------------------------------------------------------------------------
## DELEGATED CONFIG ADMIN
## -------------------------------------------------------------------------------------

# Enable the security account to create a Config multi-account, multi-region data
# aggregator.
resource "aws_organizations_delegated_administrator" "main" {
  provider = aws.mgmt_us_east_1

  service_principal = "config.amazonaws.com"
  account_id        = local.sec_account_id
}
