## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will only be created in us-east-1 of the dev
# management account, not any other account, region, nor stage.

## -------------------------------------------------------------------------------------
## ORG RESOURCES MODULE
## -------------------------------------------------------------------------------------

# Child module that declares all org resources that should be created in us-east-1 of
# each stage's management account.
module "org_resources" {
  source = "../resources"

  stage = "dev"
}
