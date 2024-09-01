output "account_alias" {
  description = "Globally unique alias of this account."
  value       = aws_iam_account_alias.main.account_alias
}

output "regional" {
  description = "All outputs from the regional module."
  value = {
    "us-east-1" : module.us_east_1,
    "us-west-2" : module.us_west_2,
  }
}
