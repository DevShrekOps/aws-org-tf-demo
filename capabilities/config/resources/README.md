# config-resources

Terraform child module that declares all Config resources that should be created in us-east-1 of each stage's management & security accounts to create a multi-account, multi-region data aggregator. Called by the **config-\<stage\>** root modules.

## External Dependencies

This module can't be applied until after trusted access is enabled between Organizations and Config in the management account, which is configured in **org-resources**.
