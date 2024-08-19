# account-baseline

Terraform child module that declares baseline resources that should be created in us-east-1 of each account in each stage, and calls the **account-baseline-regional** child module for each enabled region. Called by the root module for each account-specific Terraform config in **accounts/**.
