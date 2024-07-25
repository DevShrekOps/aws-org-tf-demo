# guardduty-dev

Terraform root module for registering the dev security account as a delegated GuardDuty administrator and automatically enabling GuardDuty in all enabled regions of all current & future AWS accounts in the dev org. Calls the **guardduty-resources** child module with providers & arguments specific to the dev org.

## External Dependencies

This module can't be applied until after trusted access is enabled between Organizations and both GuardDuty & GuardDuty's Malware Protection in the management account, which are configured in **org-resources**.
