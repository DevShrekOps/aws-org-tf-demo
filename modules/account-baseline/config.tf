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
        aws.ap_northeast_1,
        aws.ap_northeast_2,
        aws.ap_northeast_3,
        aws.ap_south_1,
        aws.ap_southeast_1,
        aws.ap_southeast_2,
        aws.ca_central_1,
        aws.eu_central_1,
        aws.eu_north_1,
        aws.eu_west_1,
        aws.eu_west_2,
        aws.eu_west_3,
        aws.sa_east_1,
        aws.us_east_1,
        aws.us_east_2,
        aws.us_west_1,
        aws.us_west_2,
      ]
    }
  }
}
