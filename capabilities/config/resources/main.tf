## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will only be created in us-east-1 of each
# stage's management or security account (depending on provider), not any other account
# nor region.

## -------------------------------------------------------------------------------------
## COMMON DATA SOURCES & LOCAL VALUES
## -------------------------------------------------------------------------------------

# Fetch the account ID of the security AWS account
data "aws_caller_identity" "sec" {
  provider = aws.sec_us_east_1
}

# Fetch the org ID from the management AWS account
data "aws_organizations_organization" "main" {
  provider = aws.mgmt_us_east_1
}

# Store as local values for easier referencing
locals {
  org_id         = data.aws_organizations_organization.main.id
  sec_account_id = data.aws_caller_identity.sec.account_id
}

## -------------------------------------------------------------------------------------
## DELEGATED CONFIG ADMIN
## -------------------------------------------------------------------------------------

# Enable the security account to create a Config multi-account, multi-region data
# aggregator.
resource "aws_organizations_delegated_administrator" "main" {
  provider = aws.mgmt_us_east_1

  service_principal = "config.amazonaws.com"
  account_id        = local.sec_account_id
}

## -------------------------------------------------------------------------------------
## CONFIG MULTI-ACCOUNT, MULTI-REGION DATA AGGREGATOR
## -------------------------------------------------------------------------------------

resource "aws_config_configuration_aggregator" "main" {
  provider = aws.sec_us_east_1

  name = "main-${var.stage}"

  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.config_org_reader.arn
  }

  depends_on = [
    # The Config aggregator can't be created until the security account has been enabled
    # as a delegated Config admin, but Terraform can't infer that dependency.
    aws_organizations_delegated_administrator.main,

    # The Config aggregator can't be created until the Config org reader role has the
    # necessary permissions, but Terraform can't infer the dependency on the IAM policy
    # attachment resource.
    aws_iam_role_policy_attachment.config_org_reader_aws_config_role_for_orgs,
  ]
}

## -------------------------------------------------------------------------------------
## CONFIG ORG READER ROLE
## -------------------------------------------------------------------------------------

# This role is used by the Config data aggregator to fetch details about other AWS
# accounts in the org to aggregate Config data from.
resource "aws_iam_role" "config_org_reader" {
  provider = aws.sec_us_east_1

  name = "config-org-reader-${var.stage}"

  assume_role_policy = data.aws_iam_policy_document.config_org_reader_assume_role.json
}

data "aws_iam_policy_document" "config_org_reader_assume_role" {
  provider = aws.sec_us_east_1

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "config_org_reader_aws_config_role_for_orgs" {
  provider = aws.sec_us_east_1

  role       = aws_iam_role.config_org_reader.name
  policy_arn = data.aws_iam_policy.aws_config_role_for_orgs.arn
}

data "aws_iam_policy" "aws_config_role_for_orgs" {
  provider = aws.sec_us_east_1

  name        = "AWSConfigRoleForOrganizations"
  path_prefix = "/service-role/"
}

## -------------------------------------------------------------------------------------
## S3 BUCKET FOR CONFIG LOGS
## -------------------------------------------------------------------------------------

# A separate bucket is created for each log type to avoid complications when supporting
# a bunch of log types. When a single bucket is used for lots of log types that each
# require their own policy statements, the bucket policy can become difficult to
# understand and there's a risk of running into a policy size limit. Using a single
# bucket for multiple log types can also make it trickier to configure event
# notifications in some cases, since wildcards aren't supported.
module "baseline_s3_bucket" {
  # This module declares an S3 bucket with a baseline configuration that should be used
  # for all buckets in this git repo unless there's a specific reason not to.
  source = "../../../modules/baseline-s3-bucket"

  providers = {
    aws = aws.sec_us_east_1
  }

  stage = var.stage

  # If the scope of this bucket is ever changed (or if any other change is ever made
  # that results in this bucket being renamed), then the hardcoded reference to this
  # bucket name in the Config delivery channel resource declaration in the
  # account-baseline-regional module must be updated accordingly.
  scope = "config-logs"

  # The bucket policy will consist of a policy document that's the same across all
  # buckets combined with the policy document referenced below that's specific to
  # Config.
  extra_bucket_policy_documents = [data.aws_iam_policy_document.main.json]
}

# This policy document is passed into the baseline_s3_bucket module (via the
# extra_bucket_policy_documents variable) which creates the bucket policy for the Config
# logs bucket by combining this policy document (which is specific to Config) with
# another policy document that's the same across all buckets.
data "aws_iam_policy_document" "main" {
  statement {
    sid    = "AllowAccessByConfigSvcPrincipal"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    # Unlike the bucket_arn output, unsafe_bucket_arn isn't configured with an explicit
    # dependency on the bucket policy, thus allowing it to be referenced in this policy.
    # Also, the AWS docs provide an example policy that restricts the resources for
    # s3:PutObject to granular paths that include the source account ID, but I don't
    # think such granularity adds any value, especially in this case, since the bucket
    # will need to receive Config logs from all accounts in the org, and thus the source
    # account ID would need to be a wildcard anyway.
    resources = [
      module.baseline_s3_bucket.unsafe_bucket_arn,
      "${module.baseline_s3_bucket.unsafe_bucket_arn}/*",
    ]

    # The AWS docs provide an example policy that includes two conditions, one to
    # enforce that the bucket owner has full control over objects created by the Config
    # service principal, and another to restrict which AWS account(s) the Config service
    # principal can write to this bucket from. The first condition isn't necessary here,
    # since ACLs are disabled by baseline_s3_bucket, meaning the bucket owner
    # automatically owns all objects that are created in it, even ones created by
    # service principals. The second condition is important because it prevents a
    # confused deputy attack in which a 3rd party could configure Config in their AWS
    # account to write logs to this bucket, but rather than restrict access by specific
    # AWS account IDs (which would require updating this policy each time a new account
    # was created in the org, and would eventually run into a max bucket policy size
    # limit), access is restricted by org ID so that the Config service principal can
    # write to this bucket from any current & future account in the org.
    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values   = [local.org_id]
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  provider = aws.sec_us_east_1

  bucket = module.baseline_s3_bucket.bucket_id

  rule {
    id = "delete-old-files-${var.stage}"

    status = "Enabled"

    # Apply the rule to all objects in the bucket
    filter {}

    # Since this is just a demo, minimize costs by deleting files after one day. In a
    # real deployment, the expiration should be much higher, at least in prod. Even if
    # you're ingesting log files into a SIEM, it's probably worth keeping the log files
    # around in S3 as a backup for at least a couple of weeks.
    expiration {
      days = 1
    }
  }
}
