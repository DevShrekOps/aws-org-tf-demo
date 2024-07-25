## -------------------------------------------------------------------------------------
## LOCAL VALUES
## -------------------------------------------------------------------------------------

locals {
  # Keys of accounts to create in the org. An account's key is included in its name and
  # email. The list is ingested from a separate file because it's used by more than one
  # Terraform config.
  account_keys = toset(compact(split("\n", file("../../../account-keys"))))
}

## -------------------------------------------------------------------------------------
## ORGANIZATION
## -------------------------------------------------------------------------------------

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

## -------------------------------------------------------------------------------------
## ACCOUNT FACTORY
## -------------------------------------------------------------------------------------

resource "aws_organizations_account" "main" {
  # The for_each uses account key as the key (as opposed to a numeric index) for more
  # expressive plans & state files and so that if an account is removed from the list it
  # doesn't impact other accounts.
  for_each = local.account_keys

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
