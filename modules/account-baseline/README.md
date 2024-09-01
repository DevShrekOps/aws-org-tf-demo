# account-baseline

Terraform child module that declares baseline resources that should be created in us-east-1 of each account in each stage, and calls the **account-baseline-regional** child module for each allowed region. Called by the root module for each account-specific Terraform config in **accounts/**.

## External Dependencies

This module can't be applied until after an S3 bucket for storing Config logs is created in the current stage's security account, which is declared in the **config** capability.
