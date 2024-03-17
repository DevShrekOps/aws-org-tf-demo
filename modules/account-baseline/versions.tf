# See README.md in this repo's root directory for commentary on this file, including
# versioning decisions.

terraform {
  required_version = "~> 1.7.0"

  required_providers {
    aws = {
      version = "~> 5.39"
    }
  }
}
