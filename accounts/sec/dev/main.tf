## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will only be created in us-east-1 of the dev
# security account, not any other account, region, nor stage.

## -------------------------------------------------------------------------------------
## ACCOUNT BASELINE MODULE
## -------------------------------------------------------------------------------------

# Child module that declares baseline resources that should be created in us-east-1 of
# every account in this demo. 
module "account_baseline" {
  source = "../../../modules/account-baseline"

  stage       = "dev"
  account_key = "sec"
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
}
