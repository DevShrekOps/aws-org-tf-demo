# guardduty-resources

Terraform child module that declares all GuardDuty resources that should only be created once per stage, and calls the **guardduty-resources-regional** child module for each enabled region. Called by the **guardduty-dev** and **guardduty-prod** root modules.

## External Dependencies

This module can't be applied until after trusted access is enabled between Organizations and both GuardDuty & GuardDuty's Malware Protection in the management account, which are currently configured in **mgmt-resources**.
