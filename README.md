# aws-org-tf-demo

Demo multi-account AWS Organization created mostly with Terraform.

## AWS Accounts

Each AWS account in this demo is represented by its own Terraform root module in the **accounts/\<account-type>/\<stage>/** directory. For example, the root module for the dev management account is located in **accounts/mgmt/dev/**.

In the future, it might make sense to have multiple root modules representing different aspects of the same account. But for now having one root module per account is the simplest approach.

## Manual Actions

Although the goal of this demo is to perform all actions via Terraform, there'll inevitably be a need to perform some actions manually (e.g., via the AWS console). Each root module will include a **README.md** file with a log of manual actions that were performed in the associated account.

## Deployment Role

Each AWS account in this demo contains an IAM role named **tf-deployer-(prod|dev)** that's used for all Terraform deployments into the account. This role is created manually in the prod & dev management accounts. In all other accounts, this role is created automatically when the account is created via AWS Organizations.

The prod role can be assumed by admins in the prod management account, and the dev role can be assumed by admins in the dev management account.

This role is granted full admin access to its account. In a locked down environment, it might make sense to grant this role least privilege access to its account. But doing so is difficult & laborious, especially if the role will be creating IAM roles, since preventing privilege escalation will likely require advanced mechanisms to be implemented, such as enforcing IAM Permission Boundaries on all roles created by this role. In most cases (including this demo), the cost is probably greater than the benefit.
