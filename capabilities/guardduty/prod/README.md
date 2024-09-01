# guardduty-prod

Terraform root module for registering the prod security account as a delegated GuardDuty administrator in each allowed region of the prod management account, and configuring GuardDuty in each allowed region of the prod security account to automatically enable GuardDuty in all allowed regions of all current & future AWS accounts in the prod org. Calls the **guardduty-resources** child module with prod-specific providers & arguments.

## External Dependencies

This module can't be applied until after trusted access is enabled between Organizations and both GuardDuty & GuardDuty's Malware Protection in the management account, which are configured in **org-resources**.
