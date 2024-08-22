# config

Terraform configs for registering each stage's security account as a delegated Config administrator in us-east-1 of each stage's management account, and creating a multi-account, multi-region data aggregator in us-east-1 of each stage's security account.

## Directories

- **\<stage\>:** Root module that calls the **config-resources** child module with stage-specific providers & arguments.
- **resources:** Child module that declares all Config resources that should be created in us-east-1 of each stage's management & security accounts to create a multi-account, multi-region data aggregator.

## External Dependencies

These modules can't be applied until after trusted access is enabled between Organizations and Config in the management account, which is configured in **org-resources**.
