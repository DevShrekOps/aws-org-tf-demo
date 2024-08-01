# org

Terraform configs for creating an organization in us-east-1 of each stage's management account. Includes an account factory for creating new member accounts in the org.

## Directories

- **\<stage\>:** Root module that calls the **org-resources** child module with stage-specific provider & arguments.
- **resources:** Child module that declares all org resources that should be created in us-east-1 of each stage's management account.
