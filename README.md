# aws-org-tf-demo

Demo multi-account AWS Organization created mostly with Terraform.

## AWS Accounts

Each AWS account in this demo is represented by its own Terraform root module in the **accounts/\<account-type>/\<stage>/** directory. For example, the root module for the dev management account is located in **accounts/mgmt/dev/**.

In the future, it might make sense to have multiple root modules representing different aspects of the same account. But for now having one root module per account is the simplest approach.

## Manual Actions

Although the goal of this demo is to perform all actions via Terraform, there'll inevitably be a need to perform some actions manually (e.g., via the AWS console). Each root module will include a **README.md** file with a log of manual actions that were performed in the associated account.
