# guardduty-resources-regional

Terraform child module that declares all resources specific to the GuardDuty capability that should be created in each enabled region of the management and security accounts. Called once for each enabled region by the **guardduty-resources** child module.

## External Dependencies

This module can't be applied until after trusted access is enabled between Organizations and both GuardDuty & GuardDuty's Malware Protection in the management account, which are currently configured in **mgmt-resources**.
