# This module declares a baseline set of resources that's created in every AWS account
# in this demo.
module "account_baseline" {
  source = "../../../modules/account-baseline"

  stage       = "prod"
  account_key = "sec"
}

# This module declares all resources specific to security accounts.
module "sec_resources" {
  source = "../resources"

  stage           = "prod"
  mgmt_account_id = "339712815005"
}
