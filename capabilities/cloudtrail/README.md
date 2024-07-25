# cloudtrail

Terraform modules for registering each stage's security account as a delegated CloudTrail administrator and creating an organization trail.

## Directories

- **prod:** Root module that calls the **cloudtrail-resources** child module with providers & arguments that are specific to the prod org.
- **dev:** Root module that calls the **cloudtrail-resources** child module with providers & arguments specific to the dev org.
- **resources:** Child module that declares all CloudTrail resources that should only be created once per stage.

## External Dependencies

These modules can't be applied until after trusted access is enabled between Organizations and CloudTrail in the management account, which is configured in **org-resources**.
