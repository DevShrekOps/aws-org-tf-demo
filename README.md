# aws-org-tf-demo

Demo multi-account AWS Organization created mostly with Terraform.

## AWS Accounts

The **account-keys** file in this directory lists the keys of all AWS accounts in this demo. The list is stored in a separate file outside Terraform configs (as opposed to being a declared as an input variable or local value within configs) because it's used by multiple configs and should be kept in sync across them.

Each AWS account is represented by its own Terraform root module in the **accounts/\<account-key>/\<stage>/** directory. For example, the root module for the dev management account is located in **accounts/mgmt/dev/**.

Each account key has its own **resources** child module in the **accounts/\<account-key>/resources/** directory that declares all resources specific to the account key. For example, the **resources** child module for management accounts is located in **accounts/mgmt/resources/** and it declares all the resources specific to management accounts.

The **resources** child module is called by each root module representing an account with the same key. For example, the **resources** child module for management accounts is called by the root modules for both the prod & dev management accounts. This helps reduce duplication and lower the risk of drift between prod & dev versions with the same account key.

In the future, it might make sense to have multiple root modules representing different aspects of the same account. But for now having one root module per account is the simplest approach.

## Modules

The **modules/** directory contains Terraform child modules. For example, the **account-baseline** module declares a baseline set of resources that's created in every AWS account in this demo.

In the future, it might make sense to store each module in its own repo and/or version each module individually. But for now storing all modules in the same repo without separate versioning is the simplest approach.

## Manual Actions

Although the goal of this demo is to perform all actions via Terraform, there'll inevitably be a need to perform some actions manually (e.g., via the AWS console). Each root module will include a **README.md** file with a log of manual actions that were performed in the associated account.

## Deployment Role

Each AWS account in this demo contains an IAM role named **tf-deployer-(prod|dev)** that's used for all Terraform deployments into the account. This role is created manually in the prod & dev management accounts. In all other accounts, this role is created automatically when the account is created via AWS Organizations.

The prod role can be assumed by admins in the prod management account, and the dev role can be assumed by admins in the dev management account.

This role is granted full admin access to its account. In a locked down environment, it might make sense to grant this role least privilege access to its account. But doing so is difficult & laborious, especially if the role will be creating IAM roles, since preventing privilege escalation will likely require advanced mechanisms to be implemented, such as enforcing IAM Permission Boundaries on all roles created by this role. In most cases (including this demo), the cost is probably greater than the benefit.

## Version Constraints

In each Terraform root & child module, there's a file named **config.tf** that contains configuration related to Terraform, providers, & state. Within this file there's a "VERSIONS" section that declares the providers that are required by the module along with version constraints of each provider and Terraform itself. I like storing this info in a different file than **main.tf** because typically versioning info is sought out separately from resource declarations.

This repo follows this guidance from HashiCorp's [Manage Terraform versions](https://developer.hashicorp.com/terraform/tutorials/configuration-language/versions) doc:

> In general, we encourage you to use the latest available version of Terraform to take advantage of the most recent features and bug fixes.

And:

> As a best practice, consider using ~> style version constraints to pin your major and minor Terraform version. Doing so will allow you and your team to use patch version updates without updating your Terraform configuration. You can then plan when you want to upgrade your configuration to use a new version of Terraform, and carefully review the changes to ensure that your project still works as intended.

This repo also follows this guidance from HashiCorp's [Provider Requirements](https://developer.hashicorp.com/terraform/language/providers/requirements#version-constraints) doc:

> Each module should at least declare the minimum provider version it is known to work with, using the >= version constraint syntax:

And:

> A module intended to be used as the root of a configuration — that is, as the directory where you'd run terraform apply — should also specify the maximum provider version it is intended to work with, to avoid accidental upgrades to incompatible new versions. The ~> operator is a convenient shorthand for allowing the rightmost component of a version to increment.

I chose the minimum version of the AWS provider by reviewing its [change log](https://github.com/hashicorp/terraform-provider-aws/blob/main/CHANGELOG.md) in reverse order and selecting the latest version that included a feature, enhancement, or bug fix that I anticipated using in this repo. To my surprise, this happened to be the latest version overall.

For maximum version, I decided to allow upgrades to both the minor & patch version (as opposed to just the patch version) to strike a pragmatic balance between ease of upgrading the provider and avoiding an unintentional breaking change.

I'll rely on the dependency lock file to enforce a specific version (e.g., among my development system and future pipeline) between upgrades.

## Providers

In **config.tf** in each Terraform root module, there's a "PROVIDERS" section that declares the configuration of each provider that's required by the module. I like storing this config in a different file than **main.tf** because typically provider config is sought out separately from resource declarations.

In most cases, the AWS provider is configured to use the **tf-deployer-(prod|dev)** role to deploy resources into the **us-east-1** region of a specific account. This prevents accidental deployment into the wrong account and/or region.

However, sometimes a root module needs to create resources in multiple accounts and/or regions. In such cases, separate AWS providers are needed for each region of each account. Unfortunately, as of Terraform v1.7, it's not possible to use `for_each` to declare multiple providers with a single provider block. Thus, a separate provider block is declared for each region of each account, resulting in a lot of duplication. This problem might be alleviated in the future with the release of Terraform Stacks.

It's up to the developer or pipeline that's performing the deployment to provide AWS credentials to Terraform with sufficient permissions to assume the deployment role in the specified account(s). As "the developer" for this demo, I'll configure the AWS CLI on my development system with two named profiles, one for the **donkey** SSO user in **mgmt-prod**, and the other for the **donkey** SSO user in **mgmt-dev**. These SSO users will have sufficient permissions to assume the deployment role in all accounts in the prod & dev orgs respectively. I'll set the **AWS_PROFILE** environment variable to the appropriate profile name before performing a deployment. If I forget to do so or if I set the environment variable to the wrong profile name, then the deployment will fail (which is much better than deploying resources into the wrong account).

## State Management

In **config.tf** in each Terraform root module, there's a "BACKEND" section that configures how the module's state is managed. I like storing this config in a separate file than **main.tf** because typically state management info is sought out separately from resource declarations.

Terraform is configured to use the **tf-state-manager-(prod|dev)** role to manage the module's state using an S3 backend. This is more resilient and team-friendly than storing state in a local state file (even if that file is checked into source control).

State files are stored in an S3 bucket named **devshrekops-demo-tf-state-(prod|dev)** in the **us-east-1** region of the **mgmt-(prod|dev)** account. State locks are stored in a DynamoDB table named **tf-state-locks-(prod|dev)** in the same region of the same account. This prevents the module's state from being interacted with by multiple actors at the same time, which could otherwise result in conflicting deployments and state corruption.

The bucket, table, & role described above are all declared in the root module for the **mgmt-(prod|dev)** account.

In the future, it might make sense to use a service like Terraform Cloud for managing state. But for now using an S3 backend strikes the best balance between resiliency, team-friendliness, & simplicity.
