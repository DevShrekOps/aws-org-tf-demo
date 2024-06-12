# See README.md in this repo's root directory for commentary on this file.

terraform {
  backend "s3" {
    bucket         = "devshrekops-demo-tf-state-prod"
    key            = "sec-prod"
    dynamodb_table = "tf-state-locks-prod"
    region         = "us-east-1"
    assume_role = {
      role_arn = "arn:aws:iam::339712815005:role/tf-state-manager-prod"
    }
  }
}
