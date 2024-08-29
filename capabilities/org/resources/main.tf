## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will only be created in us-east-1 of each
# stage's management account, not any other account nor region.

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
    "config.amazonaws.com", # Required for multi-account, multi-region data aggregation
    "guardduty.amazonaws.com",
    "malware-protection.guardduty.amazonaws.com",
    "sso.amazonaws.com", # IAM Identity Center
  ]
}

## -------------------------------------------------------------------------------------
## ORGANIZATIONAL UNITS (OUs)
## -------------------------------------------------------------------------------------

resource "aws_organizations_organizational_unit" "active" {
  name      = "active-${var.stage}"
  parent_id = aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_organizational_unit" "closed" {
  name      = "closed-${var.stage}"
  parent_id = aws_organizations_organization.main.roots[0].id
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

  parent_id = aws_organizations_organizational_unit.active.id

  close_on_deletion          = true
  iam_user_access_to_billing = "ALLOW"

  role_name = "tf-deployer-${var.stage}"

  tags = {
    # Add a tag with the account key. The original goal was to make it easier for other
    # modules that fetch accounts via a data source to reference accounts by their key,
    # but that didn't work out due to an account's tags not being included as an
    # attribute in the data source. Keeping the tag anyway since it could be useful in
    # the future.
    account-key = each.key
  }

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
