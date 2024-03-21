# See the Manual Action Log in README.md for details about manually-created resources.

# Import the org that was manually created in this account when IAM Identity Center was
# enabled.
import {
  to = module.mgmt_resources.aws_organizations_organization.main
  id = "o-pca28idqmq"
}

# Import the org-admins-dev SSO group that was manually created in this account.
import {
  to = module.mgmt_resources.aws_identitystore_group.org_admins
  id = "d-9067f854db/94784418-7091-7068-2428-0b327809cf24"
}
