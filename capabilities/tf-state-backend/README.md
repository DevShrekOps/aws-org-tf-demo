# tf-state-backend

Terraform configs for creating an S3 backend in us-east-1 of each stage's management account to store state for all the stage's Terraform configs.

## Directories

- **\<stage\>:** Root module that calls the **tf-state-backend-resources** child module with stage-specific provider & arguments.
- **resources:** Child module that declares all Terraform state backend resources that should be created in us-east-1 of each stage's management account.
