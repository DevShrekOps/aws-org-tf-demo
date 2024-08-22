# See README.md in this repo's root directory for commentary on this file.

## -------------------------------------------------------------------------------------
## VERSIONS
## -------------------------------------------------------------------------------------

terraform {
  required_version = "~> 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.39"
      configuration_aliases = [
        # us-east-1
        aws.mgmt_us_east_1,
        aws.sec_us_east_1,
      ]
    }
  }
}
