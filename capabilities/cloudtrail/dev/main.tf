## -------------------------------------------------------------------------------------
## MODULES
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
