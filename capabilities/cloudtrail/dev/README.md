# cloudtrail-dev

Terraform root module for registering the dev security account as a delegated CloudTrail administrator in us-east-1 of the dev management account, and creating an organization trail in us-east-1 of the dev security account. Calls the **cloudtrail-resources** child module with dev-specific providers & arguments.

## External Dependencies

This module can't be applied until after trusted access is enabled between Organizations and CloudTrail in the management account, which is configured in **org-resources**.
