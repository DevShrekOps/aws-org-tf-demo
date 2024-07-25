# guardduty

Terraform modules for registering each stage's security account as a delegated GuardDuty administrator and automatically enabling GuardDuty in all enabled regions of all current & future AWS accounts in each stage's org.

## Directories

- **prod:** Root module that calls the **guardduty-resources** child module with providers & arguments that are specific to the prod org.
- **dev:** Root module that calls the **guardduty-resources** child module with providers & arguments specific to the dev org.
- **resources:** Child module that declares all GuardDuty resources that should only be created once per stage, and calls the **guardduty-resources-regional** child module for each enabled region.
- **resources/regional:** Child module that declares all GuardDuty resources that should be created in each enabled region.

## External Dependencies

These modules can't be applied until after trusted access is enabled between Organizations and both GuardDuty & GuardDuty's Malware Protection in the management account, which are configured in **org-resources**.
