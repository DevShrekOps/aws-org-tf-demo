## -------------------------------------------------------------------------------------
## MODULES
## -------------------------------------------------------------------------------------

# Child module that declares all CloudTrail resources that should only be created once
# per stage.
module "cloudtrail_resources" {
  source = "../resources"

  stage = "prod"

  providers = {
    aws.mgmt_us_east_1 = aws.mgmt_us_east_1
    aws.sec_us_east_1  = aws.sec_us_east_1
  }
}
