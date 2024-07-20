# tf-state-backend-dev

Terraform root module for creating an S3 backend in us-east-1 of the dev management account to store state for all dev Terraform configs. Calls the **tf-state-backend-resources** child module with dev-specific providers & arguments.
