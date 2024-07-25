# cloudtrail-resources

Terraform child module that declares all CloudTrail resources that should be created in us-east-1 of each stage's management & security accounts. Called by the **cloudtrail-\<stage\>** root modules.

## External Dependencies

This module can't be applied until after trusted access is enabled between Organizations and CloudTrail in the management account, which is configured in **org-resources**.
