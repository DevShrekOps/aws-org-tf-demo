## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will only be created in us-east-1 of the prod
# management or security account (depending on provider), not any other account, region,
# nor stage.

## -------------------------------------------------------------------------------------
## CONFIG RESOURCES MODULE
## -------------------------------------------------------------------------------------

# Child module that declares all Config resources that should be created in us-east-1 of
# each stage's management & security accounts to create a multi-account, multi-region
# data aggregator.
module "config_resources" {
  source = "../resources"

  stage = "prod"

  providers = {
    aws.mgmt_us_east_1 = aws.mgmt_us_east_1
    aws.sec_us_east_1  = aws.sec_us_east_1
  }
}
