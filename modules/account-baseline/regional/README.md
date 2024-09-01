# account-baseline-regional

Terraform child module that declares baseline resources that should be created in each allowed region of each account in each stage. Called once for each allowed region by the **account-baseline** child module.

## External Dependencies

This module can't be applied until after an S3 bucket for storing Config logs is created in the current stage's security account, which is declared in the **config** capability.
