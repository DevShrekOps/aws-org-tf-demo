# sec

Terraform configs for creating resources in each stage's security account that aren't related to any capabilities with dedicated Terraform configs in **capabilities/**.

## Directories

- **\<stage\>:** Root module that calls the **account-baseline** and **sec-resources** child modules with stage-specific providers & arguments. Also documents any manual actions that were performed in the account.
- **resources:** Child module that declares all resources that should be created in us-east-1 of each stage's security account that aren't declared in **account-baseline** nor related to any capabilities.
