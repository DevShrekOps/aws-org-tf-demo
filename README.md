# aws-org-tf-demo

Demo multi-account AWS Organization created mostly with raw Terraform (e.g., no wrappers).

## Repo Structure

### account-keys

Plain text file that lists the keys of all AWS accounts in this demo. This file is read by the **org** capability to determine the member accounts that should be created in each stage's organization. There are currently two stages (dev & prod), but more could be added in the future.

This file is also read by the **sso** capability to ensure that certain permission sets are associated with all accounts in each stage's organization. The list of account keys is read from this file (as opposed to being fetched dynamically via a data source) because the keys must be known at plan time to be used in the `for_each` meta-argument of resource declarations.

### accounts/

For each AWS account in this demo, there's an account-specific Terraform config. The root module for each such config is in the **accounts/\<account-key\>/\<stage\>/** directory. For example, the root module for the dev management account (aka, **mgmt-dev**) is in **accounts/mgmt/dev/**.

The main purposes of account-specific Terraform configs are to:
1. Create resources that should be created in all accounts. For example, each account's alias. Such resources are declared in the **account-baseline** child module in **modules/account-baseline/** which is called by the root module for each account's Terraform config.
2. Create resources that should only be created in a single account per stage, but aren't related to any capabilities with dedicated Terraform configs in **capabilities/**. Such resources are declared in the **\<account-key\>-resources** child module in **accounts/\<account-key\>/resources/** which is called by the root module for the account's Terraform config. For example, the **mgmt-resources** child module is called by the **mgmt-dev** and **mgmt-prod** root modules. This helps reduce duplication and lower the risk of drift between stages.
3. Create resources that should only be created in a single account in a single stage, but aren't related to any capabilities with dedicated Terraform configs in **capabilities/**. Such resources are declared in the root module for the account's Terraform config. For example, a resource might be declared in **mgmt-prod** but not **mgmt-dev** to reduce costs.
5. Document manual actions that were taken in the account (e.g., via the AWS console) in **accounts/\<account-key\>/\<stage\>/README.md**.

In some cases, root & child modules in **accounts/** might call other child modules in **modules/**.

### capabilities/

A capability is a group of related resources that are created by a dedicated Terraform config (as opposed to being created as part of an account's Terraform config). There are no rigid criteria for creating a capability. One common reason is if a group of related resources will always be updated independently from other resources in the account, especially if they'll be updated often. Another common reason is if a group of related resources span multiple accounts, especially if those resources need to be created in a specific order and/or reference each other's attributes.

The root module for each capability's Terraform config is in the **capabilities/\<capability-name\>/\<stage\>/** directory. For example, the root module for the dev GuardDuty capability (aka, **guardduty-dev**) is in **capabilities/guardduty/dev/**.

Resources that should only be created in us-east-1 of the relevant AWS account(s) for each stage are declared in the **\<capability-name\>-resources** child module in **capabilities/\<capability-name\>/resources/** which is called by the root module for the capability's Terraform config. For example, the **guardduty-resources** child module is called by the **guardduty-dev** and **guardduty-prod** root modules. This helps reduce duplication and lower the risk of drift between stages.

Resources that should be created in each allowed region of the relevant AWS account(s) for each stage are declared in the **\<capability-name\>-resources-regional** child module in **capabilities/\<capability-name\>/resources/regional** which is called by its respective **\<capability-name\>-resources** child module. For example, the **guardduty-resources-regional** child module is called by the **guardduty-resources** child module, once for each allowed region.

In some cases, root & child modules in **capabilities/** might call other child modules in **modules/**.

### modules/

The **modules/** directory contains Terraform child modules that are called by multiple root and/or child modules for different accounts and/or capabilities (not just multiple root and/or child modules for different stages of a single account key or capability). For example, the **account-baseline** module declares a baseline set of resources that's created in every AWS account in this demo, and is thus called by the root module for each account's Terraform config in **accounts/**.

In the future, it might make sense to store each module in its own repo and/or version each module individually. But for now storing all modules in the same repo without separate versioning is the simplest approach.

## Regions

The main region used in this demo is us-east-1. Resources that only need to be created once per org or account are created in the us-east-1 region. However, some modules are designed to support duplicating resources across multiple regions. Such resources are referred to as "regional resources" and are typically declared in a separate "regional" submodule. For example, the **account-baseline** module declares resources that only need to be created once per account (e.g., an S3 Account Public Access Block), whereas the **account-baseline-regional** submodule declares regional resources (e.g., a Config recorder).

In a previous iteration of this demo, regional resources were created in each of the seventeen regions that are enabled in all accounts by default. This was later scaled back such that regional resources are now only created in two regions: us-east-1 and us-west-2. These two regions are referred to as "allowed regions", since a Service Control Policy (SCP) was created to explicitly deny actions in all other regions.

The two reasons this demo was scaled back to only create regional resources in us-east-1 and us-west-2 were to reduce costs (especially related to AWS Config) and duplication (e.g., due to Terraform requiring a separate provider to be declared per region per account). In a real deployment, an argument could be made that, even with a SCP in place explicitly denying actions in disallowed regions, it might still make sense to create security-related resources (e.g., a GuardDuty detector) in each enabled region (not just each allowed region), both to make it quicker to securely expand into other regions if/when the business need arises, and because SCP-based region restrictions aren't perfect (e.g., they aren't applied to the management account).

## Manual Actions

Although the goal of this demo is to perform all actions via Terraform, there'll inevitably be a need to perform some actions manually (e.g., via the AWS console). The root module for each account's Terraform config in **accounts/** contains a **README.md** file with a log of manual actions that were performed in the associated account.

## Deployment Role

Each AWS account in this demo contains an IAM role named **tf-deployer-\<stage\>** that's used for all Terraform deployments into the account. This role was created manually in each stage's management account. In all other accounts, this role is created automatically when the account is created via the **orgs** capability.

Each stage's deployment role can be assumed by admins in the same stage's management account. For example, **tf-deployer-prod** in each prod account can be assumed by admins in **mgmt-prod**.

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

In most cases, the AWS provider is configured to use the **tf-deployer-\<stage\>** role to deploy resources into the **us-east-1** region of a specific account. This prevents accidental deployment into the wrong account and/or region.

However, sometimes a root module needs to create resources in multiple accounts and/or regions. In such cases, separate AWS providers are needed for each relevant region of each relevant account. Unfortunately, as of Terraform v1.7, it's not possible to use `for_each` to declare multiple providers with a single provider block. Thus, a separate provider block is declared for each relevant region of each relevant account, resulting in a lot of duplication. This problem might be alleviated in the future with the release of Terraform Stacks.

It's up to the developer or pipeline that's performing the deployment to provide AWS credentials to Terraform with sufficient permissions to assume the deployment role in the specified account(s). As "the developer" for this demo, I'll configure the AWS CLI on my development system with two named profiles, one for the **donkey** SSO user in **mgmt-prod**, and the other for the **donkey** SSO user in **mgmt-dev**. These SSO users will have sufficient permissions to assume the deployment role in all accounts in the prod & dev orgs respectively. I'll set the **AWS_PROFILE** environment variable to the appropriate profile name before performing a deployment. If I forget to do so or if I set the environment variable to the wrong profile name, then the deployment will fail (which is much better than deploying resources into the wrong account).

## State Management

In **config.tf** in each Terraform root module, there's a "BACKEND" section that configures how the module's state is managed. I like storing this config in a separate file than **main.tf** because typically state management info is sought out separately from resource declarations.

Terraform is configured to use the **tf-state-manager-\<stage\>** role to manage the module's state using an S3 backend. This is more resilient and team-friendly than storing state in a local state file (even if that file is checked into source control).

State files are stored in an S3 bucket named **devshrekops-demo-tf-state-\<stage\>** in the **us-east-1** region of the **mgmt-\<stage\>** account. State locks are stored in a DynamoDB table named **tf-state-locks-\<stage\>** in the same region of the same account. This prevents the module's state from being interacted with by multiple actors at the same time, which could otherwise result in conflicting deployments and state corruption.

The bucket, table, & role described above are all created by the **tf-state-backend** capability.

In the future, it might make sense to use a service like Terraform Cloud for managing state. But for now using an S3 backend strikes the best balance between resiliency, team-friendliness, & simplicity.
