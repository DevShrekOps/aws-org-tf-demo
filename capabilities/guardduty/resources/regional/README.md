# guardduty-resources-regional

Terraform child module that declares all GuardDuty resources that should be created in each allowed region of each stage's management and security accounts. Called once for each allowed region by the **guardduty-resources** child module.

## External Dependencies

This module can't be applied until after trusted access is enabled between Organizations and both GuardDuty & GuardDuty's Malware Protection in the management account, which are configured in **org-resources**.
