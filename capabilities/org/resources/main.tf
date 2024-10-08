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

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
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

## -------------------------------------------------------------------------------------
## ACTIVE OU
## -------------------------------------------------------------------------------------

resource "aws_organizations_organizational_unit" "active" {
  name      = "active-${var.stage}"
  parent_id = aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_policy_attachment" "active_baseline_guardrails" {
  target_id = aws_organizations_organizational_unit.active.id
  policy_id = aws_organizations_policy.baseline_guardrails.id
}

## -------------------------------------------------------------------------------------
## CLOSED OU
## -------------------------------------------------------------------------------------

resource "aws_organizations_organizational_unit" "closed" {
  name      = "closed-${var.stage}"
  parent_id = aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_policy_attachment" "closed_deny_all" {
  target_id = aws_organizations_organizational_unit.closed.id
  policy_id = aws_organizations_policy.deny_all.id
}

## -------------------------------------------------------------------------------------
## BASELINE-GUARDRAILS SCP
## -------------------------------------------------------------------------------------

resource "aws_organizations_policy" "baseline_guardrails" {
  name        = "baseline-guardrails-${var.stage}"
  type        = "SERVICE_CONTROL_POLICY"
  description = "Baseline security controls applied to all AWS accounts."
  content     = data.aws_iam_policy_document.baseline_guardrails.json
}

data "aws_iam_policy_document" "baseline_guardrails" {
  statement {
    sid       = "DenyActionsInDisallowedRegions"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values = [
        "us-east-1", # N. Virginia (includes global services)
        "us-west-2", # Oregon
      ]
    }
  }

  # Don't allow any principal other than the Terraform deployer role to create, modify,
  # & delete tags that begin with "devshrekops:demo:". These tags are reserved for use
  # by the Terraform configs in this repo.
  statement {
    sid       = "ProtectTerraformTags"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:TagKeys"
      values = [
        "devshrekops:demo:*",
      ]
    }

    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalARN"
      values = [
        "arn:aws:iam::*:role/tf-deployer-${var.stage}",
      ]
    }
  }

  # Don't allow certain write actions to be performed by any principal other than the
  # Terraform deployer role, regardless of any other factors, such as resource ARN or
  # tags.
  statement {
    sid    = "SimpleGuardrails"
    effect = "Deny"
    actions = [
      "cloudtrail:Deregister*",
      "cloudtrail:Register*",
      "config:Delete*",
      "config:Put*",
      "config:Tag*",
      "config:Untag*",
      "guardduty:Accept*",
      "guardduty:Create*",
      "guardduty:Decline*",
      "guardduty:Delete*",
      "guardduty:Disable*",
      "guardduty:Disassociate*",
      "guardduty:Enable*",
      "guardduty:Invite*",
      "guardduty:Start*",
      "guardduty:Stop*",
      "guardduty:Tag*",
      "guardduty:Untag*",
      "guardduty:Update*",
      "iam:Add*",
      "iam:Attach*",
      "iam:Create*",
      "iam:Deactivate*",
      "iam:Delete*",
      "iam:Detach*",
      "iam:Enable*",
      "iam:Put*",
      "iam:Remove*",
      "iam:Reset*",
      "iam:Resync*",
      "iam:Set*",
      "iam:Tag*",
      "iam:Untag*",
      "iam:Update*",
      "iam:Upload*",
      "organizations:Accept*",
      "organizations:Attach*",
      "organizations:Cancel*",
      "organizations:Close*",
      "organizations:Create*",
      "organizations:Decline*",
      "organizations:Delete*",
      "organizations:Deregister*",
      "organizations:Detach*",
      "organizations:Disable*",
      "organizations:Enable*",
      "organizations:Invite*",
      "organizations:Leave*",
      "organizations:Move*",
      "organizations:Put*",
      "organizations:Register*",
      "organizations:Remove*",
      "organizations:Tag*",
      "organizations:Untag*",
      "organizations:Update*",
      "s3:Associate*",
      "s3:CreateAccess*",
      "s3:CreateMulti*",
      "s3:CreateStorage*",
      "s3:DeleteAccess*",
      "s3:DeleteMulti*",
      "s3:DeleteStorage*",
      "s3:Disassociate*",
      "s3:PutAccess*",
      "s3:PutAccount*",
      "s3:PutMulti*",
      "s3:PutStorage*",
      "s3:Submit*",
      "s3:Tag*",
      "s3:Untag*",
      "s3:UpdateAccess*",
      "s3:UpdateStorage*",
      "sso:Associate*",
      "sso:Attach*",
      "sso:Create*",
      "sso:Delete*",
      "sso:Detach*",
      "sso:Disassociate*",
      "sso:Import*",
      "sso:Provision*",
      "sso:Put*",
      "sso:Start*",
      "sso:Tag*",
      "sso:Untag*",
      "sso:Update*",
      "sso-directory:Add*",
      "sso-directory:Complete*",
      "sso-directory:Create*",
      "sso-directory:Delete*",
      "sso-directory:Disable*",
      "sso-directory:Enable*",
      "sso-directory:Import*",
      "sso-directory:Remove*",
      "sso-directory:Start*",
      "sso-directory:Update*",
      "sso-directory:Verify*",
    ]
    resources = ["*"]

    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalARN"
      values = [
        "arn:aws:iam::*:role/tf-deployer-${var.stage}",
      ]
    }
  }

  # Don't allow certain write actions to be performed by any principal other than the
  # Terraform deployer role on resources that have a "devshrekops:demo:stage" tag.
  statement {
    sid    = "TagBasedGuardrails"
    effect = "Deny"
    actions = [
      "cloudtrail:Add*",
      "cloudtrail:Delete*",
      "cloudtrail:Put*",
      "cloudtrail:Remove*",
      "cloudtrail:Start*",
      "cloudtrail:Stop*",
      "cloudtrail:Update*",
    ]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/devshrekops:demo:stage"
      values   = ["*"]
    }

    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalARN"
      values = [
        "arn:aws:iam::*:role/tf-deployer-${var.stage}",
      ]
    }
  }

  # Don't allow certain S3 write actions to be performed by any principal other than the
  # Terraform deployer role on buckets with names beginning with "devshrekops-demo-"
  # (including objects in those buckets). This guardrail is based on bucket name instead
  # of tags because AWS doesn't support tag-based policies for actions that target
  # buckets, and it's often not practical to tag each object.
  statement {
    sid    = "ProtectS3Buckets"
    effect = "Deny"
    actions = [
      "s3:Abort*",
      "s3:Bypass*",
      "s3:DeleteBucket*",
      "s3:DeleteObject*",
      "s3:Initiate*",
      "s3:Object*",
      "s3:Pause*",
      "s3:PutAccelerate*",
      "s3:PutAnalytics*",
      "s3:PutBucket*",
      "s3:PutEncryption*",
      "s3:PutIntelligent*",
      "s3:PutInventory*",
      "s3:PutLifecycle*",
      "s3:PutMetrics*",
      "s3:PutObject*",
      "s3:PutReplication*",
      "s3:Replicate*",
      "s3:Restore*",
    ]
    resources = ["arn:aws:s3:::devshrekops-demo-*"]

    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalARN"
      values = [
        "arn:aws:iam::*:role/tf-deployer-${var.stage}",
      ]
    }
  }
}

## -------------------------------------------------------------------------------------
## DENY-ALL SCP
## -------------------------------------------------------------------------------------

resource "aws_organizations_policy" "deny_all" {
  name        = "deny-all-${var.stage}"
  type        = "SERVICE_CONTROL_POLICY"
  description = "Deny all actions on all resources by all principals."
  content     = data.aws_iam_policy_document.deny_all.json
}

data "aws_iam_policy_document" "deny_all" {
  statement {
    sid       = "DenyAllActionsOnAllResources"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]
  }
}
