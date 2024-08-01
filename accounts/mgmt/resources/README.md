# mgmt-resources

Terraform child module that declares all resources that should be created in us-east-1 of each stage's management account that aren't declared in the **account-baseline** child module nor related to any capabilities with dedicated Terraform configs in **capabilities/**. Called by the **mgmt-\<stage\>** root modules.
