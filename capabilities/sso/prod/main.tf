## -------------------------------------------------------------------------------------
## LOCALS
## -------------------------------------------------------------------------------------

# If this locals block becomes inconveniently long, then it probably makes sense to
# split it up into one or more separate files, but for now I'd rather have this file be
# longer than there be more files in the directory.
locals {
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

# Child module that declares all SSO resources that should be created in us-east-1 of
# each stage's management account.
module "sso_resources" {
  source = "../resources"

  stage          = "prod"
  sso_users      = local.sso_users
  sso_org_admins = local.sso_org_admins
}
