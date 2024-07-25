# cloudtrail

Terraform modules for registering each stage's security account as a delegated CloudTrail administrator in us-east-1 of each stage's management account, and creating an organization trail in us-east-1 of each stage's security account.

## Directories

- **\<stage\>:** Root module that calls the **cloudtrail-resources** child module with stage-specific providers & arguments.
- **resources:** Child module that declares all CloudTrail resources that should be created in us-east-1 of each stage's management & security accounts.

## External Dependencies

These modules can't be applied until after trusted access is enabled between Organizations and CloudTrail in the management account, which is configured in **org-resources**.
