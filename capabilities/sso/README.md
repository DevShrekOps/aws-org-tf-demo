# sso

Terraform configs for creating an IAM Identity Center (SSO) instance in us-east-1 of each stage's management account, along with SSO users, groups, & permission sets.

## Directories

- **\<stage\>:** Root module that calls the **org-sso** child module with stage-specific provider & arguments.
- **resources:** Child module that declares all SSO resources that should be created in us-east-1 of each stage's management account.
