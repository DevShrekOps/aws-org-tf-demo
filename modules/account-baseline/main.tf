## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will be created in us-east-1 of each account
# in each stage, but not any other region.

## -------------------------------------------------------------------------------------
## ACCOUNT ALIAS
## -------------------------------------------------------------------------------------

# Prefix with "devshrekops-" to reduce chance of naming collision with other customers
# and include "demo-" to reduce chance of naming collision with other DevShrekOps
# projects.
resource "aws_iam_account_alias" "main" {
  provider = aws.us_east_1

  account_alias = "devshrekops-demo-${var.account_key}-${var.stage}"
}

## -------------------------------------------------------------------------------------
## S3 ACCOUNT PUBLIC ACCESS BLOCK
## -------------------------------------------------------------------------------------

# Drastically reduce the chances of an S3 bucket being accidentally opened to the public
resource "aws_s3_account_public_access_block" "main" {
  provider = aws.us_east_1

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

## -------------------------------------------------------------------------------------
## SERVICE-LINKED ROLE FOR CONFIG
## -------------------------------------------------------------------------------------

# Used by the Config recorder that's created in each region via the regional module. I
# would've preferred to declare it in the standalone config capability so that it'd be
# declared side-by-side with other Config-related resources, but because it needs to be
# created in each account, it's more practical to declare it here instead. Otherwise,
# the config capability modules would have to be updated with new AWS providers each
# time a new account was created in the org.
resource "aws_iam_service_linked_role" "config" {
  provider = aws.us_east_1

  aws_service_name = "config.amazonaws.com"
}

## -------------------------------------------------------------------------------------
## REGIONAL MODULE
## -------------------------------------------------------------------------------------

# Child module that declares baseline resources that should be created in each enabled
# region of each account in each stage. Unfortunately, as of Terraform v1.7, it's not
# possible to use `for_each` to call the same module multiple times with different
# providers. Thus, a separate module block is declared for each region, resulting in a
# lot of duplication. This problem might be alleviated in the future with the release of
# Terraform Stacks.

module "ap_northeast_1" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.ap_northeast_1
  }
}

module "ap_northeast_2" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.ap_northeast_2
  }
}

module "ap_northeast_3" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.ap_northeast_3
  }
}

module "ap_south_1" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.ap_south_1
  }
}

module "ap_southeast_1" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.ap_southeast_1
  }
}

module "ap_southeast_2" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.ap_southeast_2
  }
}

module "ca_central_1" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.ca_central_1
  }
}

module "eu_central_1" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.eu_central_1
  }
}

module "eu_north_1" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.eu_north_1
  }
}

module "eu_west_1" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.eu_west_1
  }
}

module "eu_west_2" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.eu_west_2
  }
}

module "eu_west_3" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.eu_west_3
  }
}

module "sa_east_1" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.sa_east_1
  }
}

module "us_east_1" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.us_east_1
  }
}

module "us_east_2" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.us_east_2
  }
}

module "us_west_1" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.us_west_1
  }
}

module "us_west_2" {
  source = "./regional"

  stage               = var.stage
  config_svc_role_arn = aws_iam_service_linked_role.config.arn

  providers = {
    aws = aws.us_west_2
  }
}
