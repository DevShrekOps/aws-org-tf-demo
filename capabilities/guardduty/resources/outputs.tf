output "regional" {
  description = "All outputs from the regional module."
  value = {
    "us-east-1" : module.us_east_1,
    "us-west-2" : module.us_west_2,
  }
}
