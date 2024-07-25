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
## MODULES
## -------------------------------------------------------------------------------------

# Child module that declares all GuardDuty resources that should be created in each
# enabled region of each stage's management & security accounts. Unfortunately, as of
# Terraform v1.7, it's not possible to use `for_each` to call the same module multiple
# times with different providers. Thus, a separate module block is declared for each
# region, resulting in a lot of duplication. This problem might be alleviated in the
# future with the release of Terraform Stacks.

module "ap_northeast_1" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_ap_northeast_1
    aws.sec  = aws.sec_ap_northeast_1
  }
}

module "ap_northeast_2" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_ap_northeast_2
    aws.sec  = aws.sec_ap_northeast_2
  }
}

module "ap_northeast_3" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_ap_northeast_3
    aws.sec  = aws.sec_ap_northeast_3
  }
}

module "ap_south_1" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_ap_south_1
    aws.sec  = aws.sec_ap_south_1
  }
}

module "ap_southeast_1" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_ap_southeast_1
    aws.sec  = aws.sec_ap_southeast_1
  }
}

module "ap_southeast_2" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_ap_southeast_2
    aws.sec  = aws.sec_ap_southeast_2
  }
}

module "ca_central_1" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_ca_central_1
    aws.sec  = aws.sec_ca_central_1
  }
}

module "eu_central_1" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_eu_central_1
    aws.sec  = aws.sec_eu_central_1
  }
}

module "eu_north_1" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_eu_north_1
    aws.sec  = aws.sec_eu_north_1
  }
}

module "eu_west_1" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_eu_west_1
    aws.sec  = aws.sec_eu_west_1
  }
}

module "eu_west_2" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_eu_west_2
    aws.sec  = aws.sec_eu_west_2
  }
}

module "eu_west_3" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_eu_west_3
    aws.sec  = aws.sec_eu_west_3
  }
}

module "sa_east_1" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_sa_east_1
    aws.sec  = aws.sec_sa_east_1
  }
}

module "us_east_1" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_us_east_1
    aws.sec  = aws.sec_us_east_1
  }
}

module "us_east_2" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_us_east_2
    aws.sec  = aws.sec_us_east_2
  }
}

module "us_west_1" {
  source = "./regional"

  stage = var.stage

  providers = {
    aws.mgmt = aws.mgmt_us_west_1
    aws.sec  = aws.sec_us_west_1
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
