# This module declares a baseline set of resources that's created in every AWS account
# in this demo.
module "account_baseline" {
  source = "../../../modules/account-baseline"

  stage       = "dev"
  account_key = "sec"
}
