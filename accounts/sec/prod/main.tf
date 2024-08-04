## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will only be created in us-east-1 of the prod
# security account, not any other account, region, nor stage.

## -------------------------------------------------------------------------------------
## ACCOUNT BASELINE MODULE
## -------------------------------------------------------------------------------------

# Child module that declares baseline resources that should be created in us-east-1 of
# every account in this demo. 
module "account_baseline" {
  source = "../../../modules/account-baseline"

  stage       = "prod"
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

  stage           = "prod"
  mgmt_account_id = "339712815005"
}
