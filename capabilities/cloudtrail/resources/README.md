# cloudtrail-resources

Terraform child module that declares all CloudTrail resources that should only be created once per stage. Called by the **cloudtrail-dev** and **cloudtrail-prod** root modules.

## External Dependencies

This module can't be applied until after trusted access is enabled between Organizations and CloudTrail in the management account, which is configured in **org-resources**.
