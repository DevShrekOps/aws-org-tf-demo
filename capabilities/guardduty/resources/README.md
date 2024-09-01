# guardduty-resources

Terraform child module that declares all GuardDuty resources that should only be created in us-east-1 of each stage's management & security accounts, and calls the **guardduty-resources-regional** child module for each allowed region. Called by the **guardduty-\<stage\>** root modules.

## External Dependencies

This module can't be applied until after trusted access is enabled between Organizations and both GuardDuty & GuardDuty's Malware Protection in the management account, which are configured in **org-resources**.
