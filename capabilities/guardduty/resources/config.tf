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
        # ap-northeast-1
        aws.mgmt_ap_northeast_1,
        aws.sec_ap_northeast_1,
        # ap-northeast-2
        aws.mgmt_ap_northeast_2,
        aws.sec_ap_northeast_2,
        # ap-northeast-3
        aws.mgmt_ap_northeast_3,
        aws.sec_ap_northeast_3,
        # ap-south-1
        aws.mgmt_ap_south_1,
        aws.sec_ap_south_1,
        # ap-southeast-1
        aws.mgmt_ap_southeast_1,
        aws.sec_ap_southeast_1,
        # ap-southeast-2
        aws.mgmt_ap_southeast_2,
        aws.sec_ap_southeast_2,
        # ca-central-1
        aws.mgmt_ca_central_1,
        aws.sec_ca_central_1,
        # eu-central-1
        aws.mgmt_eu_central_1,
        aws.sec_eu_central_1,
        # eu-north-1
        aws.mgmt_eu_north_1,
        aws.sec_eu_north_1,
        # eu-west-1
        aws.mgmt_eu_west_1,
        aws.sec_eu_west_1,
        # eu-west-2
        aws.mgmt_eu_west_2,
        aws.sec_eu_west_2,
        # eu-west-3
        aws.mgmt_eu_west_3,
        aws.sec_eu_west_3,
        # sa-east-1
        aws.mgmt_sa_east_1,
        aws.sec_sa_east_1,
        # us-east-1
        aws.mgmt_us_east_1,
        aws.sec_us_east_1,
        # us-east-2
        aws.mgmt_us_east_2,
        aws.sec_us_east_2,
        # us-west-1
        aws.mgmt_us_west_1,
        aws.sec_us_west_1,
        # us-west-2
        aws.mgmt_us_west_2,
        aws.sec_us_west_2,
      ]
    }
  }
}
