# config-dev

Terraform root module for registering the dev security account as a delegated Config administrator in us-east-1 of the dev management account, and creating a multi-account, multi-region data aggregator in us-east-1 of the dev security account. Calls the **config-resources** child module with dev-specific providers & arguments.

## External Dependencies

This module can't be applied until after trusted access is enabled between Organizations and Config in the management account, which is configured in **org-resources**.
