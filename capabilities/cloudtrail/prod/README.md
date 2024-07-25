# cloudtrail-prod

Terraform root module for registering the prod security account as a delegated CloudTrail administrator in us-east-1 of the prod management account, and creating an organization trail in us-east-1 of the prod security account. Calls the **cloudtrail-resources** child module with prod-specific providers & arguments.

## External Dependencies

This module can't be applied until after trusted access is enabled between Organizations and CloudTrail in the management account, which is configured in **org-resources**.
