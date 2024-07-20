## -------------------------------------------------------------------------------------
## MODULES
## -------------------------------------------------------------------------------------

# Child module that declares all Terraform state backend resources that should be
# created in us-east-1 of each stage's management account.
module "tf_state_backend_resources" {
  source = "../resources"

  stage = "dev"
}
