## -------------------------------------------------------------------------------------
## COMMON DATA SOURCES & LOCAL VALUES
## -------------------------------------------------------------------------------------

# Fetch the account ID & partition of the current AWS account
data "aws_caller_identity" "main" {}
data "aws_partition" "main" {}

# Store as local values for easier referencing
locals {
  account_id = data.aws_caller_identity.main.account_id
  partition  = data.aws_partition.main.partition
}

## -------------------------------------------------------------------------------------
## ORGANIZATION
## -------------------------------------------------------------------------------------

# Declare an org resource so that manually-created orgs can be imported into and managed
# by Terraform as additional service integrations & policy types are enabled over time.
resource "aws_organizations_organization" "main" {
  # Required for key features (e.g., integration with IAM Identity Center)
  feature_set = "ALL"

  # Integrate the org with other services (e.g., IAM Identity Center)
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "guardduty.amazonaws.com",
    "malware-protection.guardduty.amazonaws.com",
    "sso.amazonaws.com", # IAM Identity Center
  ]
}

locals {
  # Keys of accounts to create in the org. An account's key is included in its name and
  # email. If this list becomes inconveniently long, then it probably makes sense to
  # move it to its own file, but for now I'd rather have this file be longer than there
  # be more files in the directory.
  account_keys = [
    "mgmt", # management account
    "sec",  # security account
  ]
}

resource "aws_organizations_account" "main" {
  # The for_each uses account key as the key (as opposed to a numeric index) for more
  # expressive plans & state files and so that if an account is removed from the list it
  # doesn't impact other accounts.
  for_each = toset(local.account_keys)

  name  = "demo-${each.key}-${var.stage}"
  email = "devshrekops+demo-${each.key}-${var.stage}@gmail.com"

  # An OU structure will be created in the future, but for now all accounts will go into
  # the root of the org. This is the default behavior, but explicitly setting it anyway
  # so that Terraform will perform drift detection on any manual changes to parent ID.
  parent_id = aws_organizations_organization.main.roots[0].id

  close_on_deletion          = true
  iam_user_access_to_billing = "ALLOW"

  role_name = "tf-deployer-${var.stage}"

  lifecycle {
    # Configure Terraform to ignore changes to the iam_user_access_to_billing attribute
    # so that Terraform doesn't plan to recreate management accounts when imported. Also
    # ignore changes to role_name per the Terraform docs: "The Organizations API
    # provides no method for reading this information after account creation, so
    # Terraform cannot perform drift detection on its value and will always show a
    # difference for a configured value after import unless ignore_changes is used."
    ignore_changes = [iam_user_access_to_billing, role_name]
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
  for_each = aws_organizations_account.main

  principal_type = "GROUP"
  principal_id   = aws_identitystore_group.org_admins.group_id

  permission_set_arn = aws_ssoadmin_permission_set.full_admin.arn

  target_type = "AWS_ACCOUNT"
  target_id   = each.value.id

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
