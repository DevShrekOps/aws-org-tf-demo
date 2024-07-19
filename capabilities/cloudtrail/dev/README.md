# cloudtrail-dev

Terraform root module for registering the dev security account as a delegated CloudTrail administrator and creating an organization trail. Calls the **cloudtrail-resources** child module with providers & arguments specific to the dev org.

## External Dependencies

This module can't be applied until after trusted access is enabled between Organizations and CloudTrail in the management account, which is currently configured in **mgmt-resources**.
