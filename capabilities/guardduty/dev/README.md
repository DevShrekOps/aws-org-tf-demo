# guardduty-dev

Terraform root module for registering the dev security account as a delegated GuardDuty administrator in each enabled region of the dev management account, and configuring GuardDuty in each enabled region of the dev security account to automatically enable GuardDuty in all enabled regions of all current & future AWS accounts in the dev org. Calls the **guardduty-resources** child module with dev-specific providers & arguments.

## External Dependencies

This module can't be applied until after trusted access is enabled between Organizations and both GuardDuty & GuardDuty's Malware Protection in the management account, which are configured in **org-resources**.
