## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will only be created in us-east-1 of the dev
# management or security account (depending on provider), not any other account, region,
# nor stage.

## -------------------------------------------------------------------------------------
## CLOUDTRAIL RESOURCES MODULE
## -------------------------------------------------------------------------------------

# Child module that declares all CloudTrail resources that should be created in
# us-east-1 of each stage's management & security accounts.
module "cloudtrail_resources" {
  source = "../resources"

  stage = "dev"

  providers = {
    aws.mgmt_us_east_1 = aws.mgmt_us_east_1
    aws.sec_us_east_1  = aws.sec_us_east_1
  }
}
