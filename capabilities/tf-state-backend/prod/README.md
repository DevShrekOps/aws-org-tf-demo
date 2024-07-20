# tf-state-backend-prod

Terraform root module for creating an S3 backend in us-east-1 of the prod management account to store state for all prod Terraform configs. Calls the **tf-state-backend-resources** child module with prod-specific providers & arguments.
