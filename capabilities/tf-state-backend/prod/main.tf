## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will only be created in us-east-1 of the prod
# management account, not any other account, region, nor stage.

## -------------------------------------------------------------------------------------
## TF STATE BACKEND RESOURCES MODULE
## -------------------------------------------------------------------------------------

# Child module that declares all Terraform state backend resources that should be
# created in us-east-1 of each stage's management account.
module "tf_state_backend_resources" {
  source = "../resources"

  stage = "prod"
}
