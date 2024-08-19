output "account_alias" {
  description = "Globally unique alias of this account."
  value       = aws_iam_account_alias.main.account_alias
}

output "regional" {
  description = "All outputs from the regional module."
  value = {
    "ap-northeast-1" : module.ap_northeast_1,
    "ap-northeast-2" : module.ap_northeast_2,
    "ap-northeast-3" : module.ap_northeast_3,
    "ap-south-1" : module.ap_south_1,
    "ap-southeast-1" : module.ap_southeast_1,
    "ap-southeast-2" : module.ap_southeast_2,
    "ca-central-1" : module.ca_central_1,
    "eu-central-1" : module.eu_central_1,
    "eu-north-1" : module.eu_north_1,
    "eu-west-1" : module.eu_west_1,
    "eu-west-2" : module.eu_west_2,
    "eu-west-3" : module.eu_west_3,
    "sa-east-1" : module.sa_east_1,
    "us-east-1" : module.us_east_1,
    "us-east-2" : module.us_east_2,
    "us-west-1" : module.us_west_1,
    "us-west-2" : module.us_west_2,
  }
}
