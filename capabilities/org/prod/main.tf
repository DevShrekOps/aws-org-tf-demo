## -------------------------------------------------------------------------------------
## MODULES
## -------------------------------------------------------------------------------------

# Child module that declares all org resources that should be created in us-east-1 of
# each stage's management account.
module "org_resources" {
  source = "../resources"

  stage = "prod"
}
