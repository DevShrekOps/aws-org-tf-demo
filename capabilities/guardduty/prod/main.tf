## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will only be created in the specified region
# of the prod management or security account (depending on provider), not any other
# account, region, nor stage.

## -------------------------------------------------------------------------------------
## GUARDDUTY RESOURCES MODULE
## -------------------------------------------------------------------------------------

# Child module that declares all GuardDuty resources that should only be created in
# us-east-1 of each stage's management & security accounts, and calls the
# guardduty-resources-regional child module for each allowed region.
module "guardduty_resources" {
  source = "../resources"

  stage = "prod"

  providers = {
    # us-east-1
    aws.mgmt_us_east_1 = aws.mgmt_us_east_1
    aws.sec_us_east_1  = aws.sec_us_east_1
    # us-west-2
    aws.mgmt_us_west_2 = aws.mgmt_us_west_2
    aws.sec_us_west_2  = aws.sec_us_west_2
  }
}
