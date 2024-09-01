# config-resources

Terraform child module that declares all Config resources that should be created in us-east-1 of each stage's management & security accounts to create a multi-account, multi-region data aggregator. Called by the **config-\<stage\>** root modules.

## External Dependencies

This module can't be applied until after trusted access is enabled between Organizations and Config in the management account, which is configured in **org-resources**.

For the multi-account, multi-region data aggregator to aggregate logs from each allowed region of each account, a service-linked role for Config must be created in each account, a Config recorder & delivery channel must be created in each allowed region of each account, and each Config recorder must be enabled. These resources are declared in **account-baseline** and **account-baseline-regional**. I would've preferred to declare them here instead so that they'd be declared side-by-side with other Config-related resources, but because they need to be created in each account (or each allowed region of each account), it's more practical to declare them in the **account-baseline** and **account-baseline-regional** modules. Otherwise, this module would have to be updated with new AWS providers each time a new account was created in the org.
