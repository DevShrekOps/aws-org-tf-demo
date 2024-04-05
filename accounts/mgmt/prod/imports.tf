# See the Manual Action Log in README.md for details about manually-created resources.

# Import the org that was manually created in this account when IAM Identity Center was
# enabled.
import {
  to = module.mgmt_resources.aws_organizations_organization.main
  id = "o-32fecjn1ln"
}

# Import the org-admins-prod SSO group that was manually created in this account.
import {
  to = module.mgmt_resources.aws_identitystore_group.org_admins
  id = "d-9067fc28a6/04183448-d091-70b1-7e76-5f2ebfdc549e"
}

# Import the full-admin-access-prod SSO permission set that was manually created in this
# account.
import {
  to = module.mgmt_resources.aws_ssoadmin_permission_set.full_admin
  id = join(",", [
    "arn:aws:sso:::permissionSet/ssoins-72232a1562dbd133/ps-a095036f1fc365cf",
    "arn:aws:sso:::instance/ssoins-72232a1562dbd133",
  ])
}

# Import the attachment of the AWS-managed AdministratorAccess IAM policy to the
# full-admin-access-prod SSO permission set that was manually created in this account.
import {
  to = module.mgmt_resources.aws_ssoadmin_managed_policy_attachment.full_admin
  id = join(",", [
    "arn:aws:iam::aws:policy/AdministratorAccess",
    "arn:aws:sso:::permissionSet/ssoins-72232a1562dbd133/ps-a095036f1fc365cf",
    "arn:aws:sso:::instance/ssoins-72232a1562dbd133",
  ])
}

# Import the assignment of the org-admins-prod SSO group with the full-admin-access-prod
# SSO permission set to the mgmt-prod account that was manually created in this account.
import {
  to = module.mgmt_resources.aws_ssoadmin_account_assignment.org_admins_full_admin_mgmt
  id = join(",", [
    "04183448-d091-70b1-7e76-5f2ebfdc549e",
    "GROUP",
    "339712815005",
    "AWS_ACCOUNT",
    "arn:aws:sso:::permissionSet/ssoins-72232a1562dbd133/ps-a095036f1fc365cf",
    "arn:aws:sso:::instance/ssoins-72232a1562dbd133",
  ])
}

# Import the donkey SSO user that was manually created in this account.
import {
  to = module.mgmt_resources.aws_identitystore_user.main["donkey"]
  id = "d-9067fc28a6/44e82448-10c1-70e3-27d3-d17c39986d90"
}

# Import the group membership of the donkey SSO user in the org-admins-prod SSO group
# that was manually configured in this account.
import {
  to = module.mgmt_resources.aws_identitystore_group_membership.org_admins["donkey"]
  id = "d-9067fc28a6/34a8f488-a031-70f6-6346-11ed3628c66b"
}
