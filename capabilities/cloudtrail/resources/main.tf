## -------------------------------------------------------------------------------------
## NOTICE
## -------------------------------------------------------------------------------------

# Resources declared directly in this file will only be created in us-east-1 of each
# stage's management or security account (depending on provider), not any other account
# nor region.

## -------------------------------------------------------------------------------------
## COMMON DATA SOURCES & LOCAL VALUES
## -------------------------------------------------------------------------------------

# Fetch the account ID of the management & security AWS accounts
data "aws_caller_identity" "mgmt" {
  provider = aws.mgmt_us_east_1
}
data "aws_caller_identity" "sec" {
  provider = aws.sec_us_east_1
}

# Store as local values for easier referencing
locals {
  mgmt_account_id = data.aws_caller_identity.mgmt.account_id
  sec_account_id  = data.aws_caller_identity.sec.account_id
}

## -------------------------------------------------------------------------------------
## DELEGATED CLOUDTRAIL ADMIN
## -------------------------------------------------------------------------------------

# Enable the security account to create an org CloudTrail. There's probably not much
# benefit (if any) to delegating creation to the security account (as opposed to the
# management account creating it) unless the security & management accounts are managed
# by separate teams, but I'm doing it anyway as a general best practice.
resource "aws_organizations_delegated_administrator" "main" {
  provider = aws.mgmt_us_east_1

  service_principal = "cloudtrail.amazonaws.com"
  account_id        = local.sec_account_id
}

## -------------------------------------------------------------------------------------
## SERVICE-LINKED ROLE
## -------------------------------------------------------------------------------------

# Normally this role is created automatically in the mgmt account when creating an org
# CloudTrail via the AWS console, but since I'm creating the trail and all of its
# prerequisites via Terraform, this role must be explicitly created too.
resource "aws_iam_service_linked_role" "main" {
  provider = aws.mgmt_us_east_1

  aws_service_name = "cloudtrail.amazonaws.com"
}

## -------------------------------------------------------------------------------------
## CLOUDTRAIL
## -------------------------------------------------------------------------------------

# Since this is just a demo, minimize costs by sticking with the default config of only
# logging management events. In a real deployment, it's probably best to configure an
# advanced event selector to log both management & data events, especially S3 data
# events. However, if you do so, make sure to explicitly exclude the CloudTrail log
# bucket from the event selector, so as not to create an infinite loop.
# ---
# There was an "InvalidTrailNameException" error during initial creation of this trail
# in both dev & prod. In both cases, the problem was fixed by rerunning `terraform
# apply` to recreate the trail. I suspect an issue in the AWS provider related to org
# trail creation by a delegated admin, but given that it worked upon recreation, it
# doesn't seem worth pursuing.
resource "aws_cloudtrail" "main" {
  provider = aws.sec_us_east_1

  name = "main-${var.stage}"

  # The trail can't be created until after the bucket policy. Normally this means that
  # the depends_on meta-argument must be added to this resource block to configure an
  # explicit dependency on the bucket policy. But that's not required in this case
  # because the bucket is created by the baseline_s3_bucket module which already
  # configures an explicit dependency on the bucket policy when declaring the bucket_id
  # output.
  s3_bucket_name = module.baseline_s3_bucket.bucket_id

  is_organization_trail = true
  is_multi_region_trail = true

  # Make it possible to validate the integrity of log files
  enable_log_file_validation = true
}

## -------------------------------------------------------------------------------------
## S3 BUCKET
## -------------------------------------------------------------------------------------

# S3 bucket for storing log files. A separate bucket is created for each log type to
# avoid complications when supporting a bunch of log types. When a single bucket is used
# for lots of log types that each require their own policy statements, the bucket policy
# can become difficult to understand and there's a risk of running into a policy size
# limit. Using a single bucket for multiple log types can also make it trickier to
# configure event notifications in some cases, since wildcards aren't supported.
module "baseline_s3_bucket" {
  # This module declares an S3 bucket with a baseline configuration that should be used
  # for all buckets in this git repo unless there's a specific reason not to.
  source = "../../../modules/baseline-s3-bucket"

  providers = {
    aws = aws.sec_us_east_1
  }

  stage = var.stage
  scope = "cloudtrail-logs"

  # The bucket policy will consist of a policy document that's the same across all
  # buckets combined with the policy document referenced below that's specific to
  # CloudTrail.
  extra_bucket_policy_documents = [data.aws_iam_policy_document.main.json]
}

# This policy document is passed into the baseline_s3_bucket module (via the
# extra_bucket_policy_documents variable) which creates the bucket policy for the
# CloudTrail log bucket by combining this policy document (which is specific to
# CloudTrail) with another policy document that's the same across all buckets.
data "aws_iam_policy_document" "main" {
  statement {
    sid    = "AllowAccessByCloudTrailSvcPrincipal"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
      "s3:PutObject",
    ]

    # Unlike the bucket_arn output, unsafe_bucket_arn isn't configured with an explicit
    # dependency on the bucket policy, thus allowing it to be referenced in this policy.
    # Also, the AWS docs provide an example policy that restricts the resources for
    # s3:PutObject to granular paths that include the mgmt account ID and org ID, but I
    # don't think such granularity adds any value, whereas it'd make configuring this
    # resource more complex (due to needing to reference the org ID, which isn't
    # natively available in this module).
    resources = [
      module.baseline_s3_bucket.unsafe_bucket_arn,
      "${module.baseline_s3_bucket.unsafe_bucket_arn}/*",
    ]

    # The AWS docs provide an example policy that includes two conditions, one to
    # enforce that the bucket owner have full control over objects created by the
    # CloudTrail service principal, and another to restrict access to a specific trail's
    # ARN. The first condition isn't necessary here, since ACLs are disabled by the
    # baseline_s3_bucket, meaning the bucket owner automatically owns all objects that
    # are created in it, even ones created by service principals. The second condition
    # is important because it prevents a confused deputy attack in which a 3rd party
    # could configure CloudTrail in their AWS account to send logs to this bucket, but
    # rather than restrict access by a specific trail's ARN (which would make
    # configuring this resource more complex, due to needing to manually construct the
    # ARN, since the bucket policy must be created before the trail), access is
    # restricted based on account ID, which is sufficient protection against a confused
    # deputy attack. The management account's ID must be used here, despite the trail
    # being created from the security account.
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.mgmt_account_id]
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
