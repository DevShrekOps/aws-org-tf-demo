## -------------------------------------------------------------------------------------
## COMMON DATA SOURCES & LOCAL VALUES
## -------------------------------------------------------------------------------------

# Retrieve metadata about the org that's created by the org capability.
data "aws_organizations_organization" "main" {}

locals {
  # Keys of accounts to create in the org. An account's key is included in its name and
  # email. The list is ingested from a separate file because it's used by more than one
  # Terraform config.
  account_keys = toset(compact(split("\n", file("../../../account-keys"))))

  # Lookup table of account IDs by account name in format "demo-<account-key>-<stage>"
  account_ids_by_name = {
    for account in data.aws_organizations_organization.main.accounts
    : account.name => account.id
  }
}

## -------------------------------------------------------------------------------------
## IAM IDENTITY CENTER (SSO)
## -------------------------------------------------------------------------------------

# At this time, the Terraform AWS provider only provides a data source (not a resource)
# for IAM Identity Center instances. The data source doesn't allow the manually-created
# instance to be imported into and managed by Terraform, but at least it provides access
# to its attributes.
data "aws_ssoadmin_instances" "main" {}

# Store as local values for easier referencing
locals {
  sso_instance_arn      = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  sso_identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
}

# The AWS-managed AdministratorAccess IAM policy that exists in every account.
data "aws_iam_policy" "full_admin" {
  name = "AdministratorAccess"
}

resource "aws_ssoadmin_permission_set" "full_admin" {
  name             = "full-admin-access-${var.stage}"
  description      = "Grants full admin access to a ${var.stage} account"
  session_duration = "PT12H" # 12 hours

  instance_arn = local.sso_instance_arn
}

resource "aws_ssoadmin_managed_policy_attachment" "full_admin" {
  managed_policy_arn = data.aws_iam_policy.full_admin.arn
  permission_set_arn = aws_ssoadmin_permission_set.full_admin.arn

  instance_arn = local.sso_instance_arn

  # The Terraform AWS provider docs state that an explicit dependency on account
  # assignments is necessary "to ensure proper deletion order" if this resource is
  # deleted "because destruction of a managed policy attachment resource also
  # re-provisions the associated permission set to all accounts."
  depends_on = [aws_ssoadmin_account_assignment.org_admins_full_admin]
}

resource "aws_identitystore_group" "org_admins" {
  display_name = "org-admins-${var.stage}"
  description  = "Grants full admin access to all accounts in the ${var.stage} org"

  identity_store_id = local.sso_identity_store_id
}

# Grant org admins full admin access to every account
resource "aws_ssoadmin_account_assignment" "org_admins_full_admin" {
  for_each = local.account_keys

  principal_type = "GROUP"
  principal_id   = aws_identitystore_group.org_admins.group_id

  permission_set_arn = aws_ssoadmin_permission_set.full_admin.arn

  target_type = "AWS_ACCOUNT"
  target_id   = local.account_ids_by_name["demo-${each.key}-${var.stage}"]

  instance_arn = local.sso_instance_arn
}

resource "aws_identitystore_group_membership" "org_admins" {
  # The for_each uses username as the key (as opposed to a numeric index) for more
  # expressive plans & state files and so that if a user is removed from the list it
  # doesn't impact other users.
  for_each = toset(var.sso_org_admins)

  group_id  = aws_identitystore_group.org_admins.group_id
  member_id = aws_identitystore_user.main[each.key].user_id

  identity_store_id = local.sso_identity_store_id
}

resource "aws_identitystore_user" "main" {
  # Create a separate user for each element in var.sso_users. The for_each uses username
  # as the key (as opposed to a numeric index) for more expressive plans & state files
  # and so that if a user is removed from the list it doesn't impact other users.
  for_each = { for sso_user in var.sso_users : sso_user.username => sso_user }

  user_name    = each.key
  display_name = each.value.display_name

  emails {
    value   = each.value.email
    type    = "work"
    primary = true
  }

  name {
    given_name  = each.value.first_name
    family_name = each.value.last_name
  }

  identity_store_id = local.sso_identity_store_id
}
