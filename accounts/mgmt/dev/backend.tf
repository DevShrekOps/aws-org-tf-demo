# See README.md in this repo's root directory for commentary on this file. Since the
# bucket, table, & role referenced below are all declared in this root module, those
# resources had to be deployed before adding this backend config. That means the state
# for those resources was temporarily stored in a local `terraform.tfstate` file, but
# after adding this backend config and re-initializing Terraform, the local state was
# migrated to the bucket.

terraform {
  backend "s3" {
    bucket         = "devshrekops-demo-tf-state-dev"
    key            = "mgmt-dev"
    dynamodb_table = "tf-state-locks-dev"
    region         = "us-east-1"
    assume_role = {
      role_arn = "arn:aws:iam::533266992459:role/tf-state-manager-dev"
    }
  }
}
