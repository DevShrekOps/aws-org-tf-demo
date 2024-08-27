# config-prod

Terraform root module for registering the prod security account as a delegated Config administrator in us-east-1 of the dev management account, and creating a multi-account, multi-region data aggregator in us-east-1 of the prod security account. Calls the **config-resources** child module with prod-specific providers & arguments.

## External Dependencies

This module can't be applied until after trusted access is enabled between Organizations and Config in the management account, which is configured in **org-resources**.

For the multi-account, multi-region data aggregator to aggregate logs from each region of each account, a service-linked role for Config must be created in each account, a Config recorder & delivery channel must be created in each region of each account, and each Config recorder must be enabled. These resources are declared in **account-baseline** and **account-baseline-regional**. I would've preferred to declare them here instead so that they'd be declared side-by-side with other Config-related resources, but because they need to be created in each account (or each region of each account), it's more practical to declare them in the **account-baseline** and **account-baseline-regional** modules. Otherwise, this module would have to be updated with new AWS providers each time a new account was created in the org.
