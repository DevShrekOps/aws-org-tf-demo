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
