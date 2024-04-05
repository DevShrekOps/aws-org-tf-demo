# See README.md in this repo's root directory for commentary on this file, including a
# decision on how to handle credentials for the AWS provider.

provider "aws" {
  # Prevent accidental deployment into the wrong account
  assume_role {
    role_arn = "arn:aws:iam::339712815005:role/tf-deployer-prod"
  }

  # Prevent accidental deployment into the wrong region
  region = "us-east-1"
}
