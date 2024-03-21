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

# Import the full-admin-access-dev SSO permission set that was manually created in this
# account.
import {
  to = module.mgmt_resources.aws_ssoadmin_permission_set.full_admin
  id = join(",", [
    "arn:aws:sso:::permissionSet/ssoins-722327f2538a7b72/ps-8ba4e82e9024cb37",
    "arn:aws:sso:::instance/ssoins-722327f2538a7b72",
  ])
}

# Import the attachment of the AWS-managed AdministratorAccess IAM policy to the
# full-admin-access-dev SSO permission set that was manually created in this account.
import {
  to = module.mgmt_resources.aws_ssoadmin_managed_policy_attachment.full_admin
  id = join(",", [
    "arn:aws:iam::aws:policy/AdministratorAccess",
    "arn:aws:sso:::permissionSet/ssoins-722327f2538a7b72/ps-8ba4e82e9024cb37",
    "arn:aws:sso:::instance/ssoins-722327f2538a7b72",
  ])
}
