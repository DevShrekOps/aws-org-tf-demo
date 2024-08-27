# config

Terraform configs for registering each stage's security account as a delegated Config administrator in us-east-1 of each stage's management account, and creating a multi-account, multi-region data aggregator in us-east-1 of each stage's security account.

## Directories

- **\<stage\>:** Root module that calls the **config-resources** child module with stage-specific providers & arguments.
- **resources:** Child module that declares all Config resources that should be created in us-east-1 of each stage's management & security accounts to create a multi-account, multi-region data aggregator.

## External Dependencies

These modules can't be applied until after trusted access is enabled between Organizations and Config in the management account, which is configured in **org-resources**.

For the multi-account, multi-region data aggregator to aggregate logs from each region of each account, a service-linked role for Config must be created in each account, a Config recorder & delivery channel must be created in each region of each account, and each Config recorder must be enabled. These resources are declared in **account-baseline** and **account-baseline-regional**. I would've preferred to declare them here instead so that they'd be declared side-by-side with other Config-related resources, but because they need to be created in each account (or each region of each account), it's more practical to declare them in the **account-baseline** and **account-baseline-regional** modules. Otherwise, this module would have to be updated with new AWS providers each time a new account was created in the org.
