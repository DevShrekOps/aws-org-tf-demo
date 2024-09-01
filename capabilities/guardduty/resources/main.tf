## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will only be created in the specified region
# of each stage's management or security account (depending on provider), not any other
# account nor region.

## -------------------------------------------------------------------------------------
## SERVICE-LINKED ROLE
## -------------------------------------------------------------------------------------

# In member accounts, this role is created automatically as part of auto enablement in
# the org GuardDuty config in the security account, but the role isn't automatically
# created in the mgmt account, so explicitly create it here.
resource "aws_iam_service_linked_role" "main" {
  provider = aws.mgmt_us_east_1

  aws_service_name = "guardduty.amazonaws.com"
}

## -------------------------------------------------------------------------------------
## REGIONAL MODULE
## -------------------------------------------------------------------------------------

# Child module that declares all GuardDuty resources that should be created in each
# allowed region of each stage's management & security accounts. Unfortunately, as of
# Terraform v1.7, it's not possible to use `for_each` to call the same module multiple
# times with different providers. Thus, a separate module block is declared for each
# allowed region, resulting in a lot of duplication. This problem might be alleviated in
# the future with the release of Terraform Stacks.

module "us_east_1" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_us_east_1
    aws.sec  = aws.sec_us_east_1
  }
}

module "us_west_2" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_us_west_2
    aws.sec  = aws.sec_us_west_2
  }
}
