## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will be created in each enabled region of
# each stage's management or security account (depending on provider), but not any other
# account.

## -------------------------------------------------------------------------------------
## COMMON DATA SOURCES & LOCAL VALUES
## -------------------------------------------------------------------------------------

# Fetch the account ID of the security AWS account
data "aws_caller_identity" "sec" {
  provider = aws.sec
}

# Store as local value for easier referencing
locals {
  sec_account_id = data.aws_caller_identity.sec.account_id
}

## -------------------------------------------------------------------------------------
## SEC GUARDDUTY DETECTOR
## -------------------------------------------------------------------------------------

# Create a GuardDuty Detector in the current region of the security account
resource "aws_guardduty_detector" "sec" {
  provider = aws.sec
}

## -------------------------------------------------------------------------------------
## DELEGATED GUARDDUTY ADMIN
## -------------------------------------------------------------------------------------

# From the current region of the management account, configure the security account as
# the delegated GuardDuty admin in the same region. This can't be created until after
# trusted access is enabled between Organizations and GuardDuty in mgmt-resources.
resource "aws_guardduty_organization_admin_account" "main" {
  provider = aws.mgmt

  admin_account_id = local.sec_account_id

  # Wait for the GuardDuty Detector to be created in the current region of the security
  # account. Otherwise, the GuardDuty Detector would be created automatically but
  # wouldn't be tracked in Terraform state, and thus would require a data source for
  # referencing its ID in other resource declarations in this module.
  depends_on = [aws_guardduty_detector.sec]
}

## -------------------------------------------------------------------------------------
## GUARDDUTY ORG CONFIG
## -------------------------------------------------------------------------------------

resource "aws_guardduty_organization_configuration" "main" {
  provider = aws.sec

  # Automatically create a GuardDuty detector in the current region of all current &
  # future AWS accounts in the org (including the management account, despite some docs
  # indicating otherwise), and centrally manage them from the security account.
  auto_enable_organization_members = "ALL"

  detector_id = aws_guardduty_detector.sec.id

  # Wait for the security account to be configured as the delegated GuardDuty admin in
  # the current region. Otherwise, this resource would fail to be created.
  depends_on = [aws_guardduty_organization_admin_account.main]
}

# Store as local values for easier referencing
locals {
  # Also known as protection plans
  guardduty_features = toset([
    "EBS_MALWARE_PROTECTION",
    "EKS_AUDIT_LOGS",
    "LAMBDA_NETWORK_LOGS",
    "RDS_LOGIN_EVENTS",
    "RUNTIME_MONITORING",
    "S3_DATA_EVENTS",
  ])

  # As of 2024-07-11, only the RUNTIME_MONITORING feature has additional config
  additional_configuration = {
    "RUNTIME_MONITORING" = [
      "ECS_FARGATE_AGENT_MANAGEMENT",
      "EC2_AGENT_MANAGEMENT",
      "EKS_ADDON_MANAGEMENT",
    ]
  }
}

# This can't be created for EBS_MALWARE_PROTECTION until after trusted access is enabled
# between Organizations and GuardDuty's Malware Protection in the management account,
# which is currently configured in mgmt-resources.
resource "aws_guardduty_organization_configuration_feature" "main" {
  for_each = local.guardduty_features

  provider = aws.sec

  name        = each.key
  detector_id = aws_guardduty_detector.sec.id

  # Automatically enable all GuardDuty features in the current region of all current &
  # future AWS accounts in the org.
  auto_enable = "ALL"

  # Configure additional config for features that support it (currently only
  # RUNTIME_MONITORING).
  dynamic "additional_configuration" {
    for_each = lookup(local.additional_configuration, each.key, {})

    content {
      name = additional_configuration.value
      # For now, disable all additional config for features that support it (currently
      # only RUNTIME_MONITORING) because the AWS docs for the additional config is
      # confusing and I don't yet fully understand the implications of enabling it.
      auto_enable = "NONE"
    }
  }

  # Wait for the security account to be configured as the delegated GuardDuty admin in
  # the current region. Otherwise, this resource would fail to be created.
  depends_on = [aws_guardduty_organization_admin_account.main]
}
