## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will only be created in us-east-1 of the dev
# security account, not any other account, region, nor stage.

## -------------------------------------------------------------------------------------
## ACCOUNT BASELINE MODULE
## -------------------------------------------------------------------------------------

# Child module that declares baseline resources that should be created in us-east-1 of
# each account in each stage, and calls the account-baseline-regional child module for
# each enabled region.
module "account_baseline" {
  source = "../../../modules/account-baseline"

  stage       = "dev"
  account_key = "sec"

  providers = {
    aws.ap_northeast_1 = aws.ap_northeast_1
    aws.ap_northeast_2 = aws.ap_northeast_2
    aws.ap_northeast_3 = aws.ap_northeast_3
    aws.ap_south_1     = aws.ap_south_1
    aws.ap_southeast_1 = aws.ap_southeast_1
    aws.ap_southeast_2 = aws.ap_southeast_2
    aws.ca_central_1   = aws.ca_central_1
    aws.eu_central_1   = aws.eu_central_1
    aws.eu_north_1     = aws.eu_north_1
    aws.eu_west_1      = aws.eu_west_1
    aws.eu_west_2      = aws.eu_west_2
    aws.eu_west_3      = aws.eu_west_3
    aws.sa_east_1      = aws.sa_east_1
    aws.us_east_1      = aws.us_east_1
    aws.us_east_2      = aws.us_east_2
    aws.us_west_1      = aws.us_west_1
    aws.us_west_2      = aws.us_west_2
  }
}

## -------------------------------------------------------------------------------------
## SEC RESOURCES MODULE
## -------------------------------------------------------------------------------------

# Child module that declares all resources that should be created in us-east-1 of each
# stage's security account that aren't declared in `account-baseline` nor related to
# any capabilities with dedicated Terraform configs.
module "sec_resources" {
  source = "../resources"

  stage           = "dev"
  mgmt_account_id = "533266992459"

  providers = {
    aws = aws.us_east_1
  }
}
