## -------------------------------------------------------------------------------------
## LOCALS
## -------------------------------------------------------------------------------------

# If this locals block becomes inconveniently long, then it probably makes sense to
# split it up into one or more separate files, but for now I'd rather have this file be
# longer than there be more files in the directory.
locals {
  account_keys = [
    "mgmt", # management account
    "sec",  # security account
  ]

  sso_users = [
    {
      username     = "donkey"
      display_name = "Donkey"
      email        = "devshrekops+donkey@gmail.com"
      first_name   = "Donkey"
      last_name    = "Unknown"
    },
  ]

  sso_org_admins = [
    "donkey",
  ]
}

## -------------------------------------------------------------------------------------
## MODULES
## -------------------------------------------------------------------------------------

# This module declares a baseline set of resources that's created in every AWS account
# in this demo.
module "account_baseline" {
  source = "../../../modules/account-baseline"

  stage       = "dev"
  account_key = "mgmt"
}

# This module declares all resources specific to management accounts.
module "mgmt_resources" {
  source = "../resources"

  stage          = "dev"
  account_keys   = local.account_keys
  sso_users      = local.sso_users
  sso_org_admins = local.sso_org_admins
}
