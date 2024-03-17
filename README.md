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

## Version Constraints

This repo follows the common practice of creating a file named **versions.tf** in each Terraform root & child module. This file declares the providers that are required by the module along with version constraints of each provider and Terraform itself. I like storing this info in a separate file because typically versioning info is sought out in isolation (as opposed to in combination with other aspects of the module, like resource declarations).

Within **versions.tf**, this repo follows this guidance from HashiCorp's [Manage Terraform versions](https://developer.hashicorp.com/terraform/tutorials/configuration-language/versions) doc:

> In general, we encourage you to use the latest available version of Terraform to take advantage of the most recent features and bug fixes.

And:

> As a best practice, consider using ~> style version constraints to pin your major and minor Terraform version. Doing so will allow you and your team to use patch version updates without updating your Terraform configuration. You can then plan when you want to upgrade your configuration to use a new version of Terraform, and carefully review the changes to ensure that your project still works as intended.

Within **versions.tf**, this repo follows this guidance from HashiCorp's [Provider Requirements](https://developer.hashicorp.com/terraform/language/providers/requirements#version-constraints) doc:

> Each module should at least declare the minimum provider version it is known to work with, using the >= version constraint syntax:

And:

> A module intended to be used as the root of a configuration — that is, as the directory where you'd run terraform apply — should also specify the maximum provider version it is intended to work with, to avoid accidental upgrades to incompatible new versions. The ~> operator is a convenient shorthand for allowing the rightmost component of a version to increment.

I chose the minimum version of the AWS provider by reviewing its [change log](https://github.com/hashicorp/terraform-provider-aws/blob/main/CHANGELOG.md) in reverse order and selecting the latest version that included a feature, enhancement, or bug fix that I anticipated using in this repo. To my surprise, this happened to be the latest version overall.

For maximum version, I decided to allow upgrades to both the minor & patch version (as opposed to just the patch version) to strike a pragmatic balance between ease of upgrading the provider and avoiding an unintentional breaking change.

I'll rely on the dependency lock file to enforce a specific version (e.g., among my development system and future pipeline) between upgrades.

## Providers

This repo follows the common practice of creating a file named **providers.tf** in each Terraform root module. This file declares the configuration of each provider that's required by the module. I like storing this config in a separate file because typically provider config is sought out in isolation (as opposed to in combination with other aspects of the module, like resource declarations).

Within each **providers.tf**, the AWS provider is configured to use the **tf-deployer-(prod|dev)** role to deploy resources into the **us-east-1** region of a specific account. This prevents accidental deployment into the wrong account and/or region.

It's up to the developer or pipeline that's performing the deployment to provide AWS credentials to Terraform with sufficient permissions to assume the specified role in the specified account. As "the developer" for this demo, I'll configure the AWS CLI on my development system with two named profiles, one for the **donkey** SSO user in **mgmt-prod**, and the other for the **donkey** SSO user in **mgmt-dev**. These SSO users will have sufficient permissions to assume the specified role in all accounts in the prod & dev orgs respectively. I'll set the **AWS_PROFILE** environment variable to the appropriate profile name before performing a deployment. If I forget to do so or if I set the environment variable to the wrong profile name, then the deployment will fail (which is much better than deploying resources into the wrong account).
