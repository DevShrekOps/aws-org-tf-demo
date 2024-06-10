# This module declares a baseline set of resources that's created in every AWS account
# in this demo.
module "account_baseline" {
  source = "../../../modules/account-baseline"

  stage        = "prod"
  account_type = "mgmt"
}

# This module declares all resources specific to management accounts.
module "mgmt_resources" {
  source = "../resources"

  stage = "prod"

  # See accounts.tf
  account_keys = local.account_keys

  # See sso_users.tf
  sso_users      = local.sso_users
  sso_org_admins = local.sso_org_admins
}
