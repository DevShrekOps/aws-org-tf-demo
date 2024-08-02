# guardduty

Terraform configs for registering each stage's security account as a delegated GuardDuty administrator in each enabled region of each stage's management account, and configuring GuardDuty in each enabled region of each stage's security account to automatically enable GuardDuty in all enabled regions of all current & future AWS accounts in each stage's org.

## Directories

- **\<stage\>:** Root module that calls the **guardduty-resources** child module with stage-specific providers & arguments.
- **resources:** Child module that declares all GuardDuty resources that should only be created in us-east-1 of each stage's management & security accounts, and calls the **guardduty-resources-regional** child module for each enabled region.
- **resources/regional:** Child module that declares all GuardDuty resources that should be created in each enabled region of each stage's management & security accounts.

## External Dependencies

These modules can't be applied until after trusted access is enabled between Organizations and both GuardDuty & GuardDuty's Malware Protection in the management account, which are configured in **org-resources**.
