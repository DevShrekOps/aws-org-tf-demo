## -------------------------------------------------------------------------------------
## LOG S3 BUCKETS
## -------------------------------------------------------------------------------------

locals {
  # This local must exist independently of the log_bucket_policy_refs local to avoid a
  # circular dependency error, as explained in more detail in the log_baseline_s3_bucket
  # module block.
  log_types = [
    "cloudtrail",
  ]

  # A map of references to the IAM policy document data sources representing the part of
  # each log bucket policy that's specific to the associated log type. Store as a local
  # value for easier referencing in module.log_baseline_s3_bucket.
  log_bucket_policy_refs = {
    "cloudtrail" : data.aws_iam_policy_document.cloudtrail_log_bucket_policy,
  }
}

# S3 buckets for storing log files. A separate bucket is created for each log type to
# avoid complications when supporting a bunch of log types. When a single bucket is used
# for lots of log types that each require their own policy statements, the bucket policy
# can become difficult to understand and there's a risk of running into a policy size
# limit. Using a single bucket for multiple log types can also make it trickier to
# configure event notifications in some cases, since wildcards aren't supported.
module "log_baseline_s3_bucket" {
  # The for_each uses log type as the key (as opposed to a numeric index) for more
  # expressive plans & state files and so that if a log type is removed from the list it
  # doesn't impact other log types. By using a separate log_types local (as opposed to
  # log_bucket_policy_refs), Terraform is able to handle each log bucket policy document
  # depending on its associated unsafe_bucket_arn output from this module, while still
  # allowing each log bucket policy document to be passed into this same module via the
  # extra_bucket_policy_documents input variable, without causing a circular dependency
  # error. Otherwise, Terraform would've assumed that this entire module block (and
  # every resource & output declared within the module) depends on the log bucket policy
  # documents for every log type.
  for_each = toset(local.log_types)

  # This module declares an S3 bucket with a baseline configuration that should be used
  # for all buckets in this git repo unless there's a specific reason not to.
  source = "../../../modules/baseline-s3-bucket"

  stage = var.stage
  scope = "${each.key}-logs"

  # The bucket policy will consist of a policy document that's the same across all
  # buckets combined with the policy document referenced below that's specific to each
  # log type.
  extra_bucket_policy_documents = [local.log_bucket_policy_refs[each.key].json]
}

resource "aws_s3_bucket_lifecycle_configuration" "log" {
  # The key is the log type and the value is the baseline_s3_bucket for the log type
  for_each = module.log_baseline_s3_bucket

  bucket = each.value.bucket_id

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

## -------------------------------------------------------------------------------------
## CLOUDTRAIL
## -------------------------------------------------------------------------------------

# Since this is just a demo, minimize costs by sticking with the default config of only
# logging management events. In a real deployment, it's probably best to configure an
# advanced event selector to log both management & data events, especially S3 data
# events. However, if you do so, make sure to explicitly exclude the CloudTrail log
# bucket from the event selector, so as not to create an infinite loop.
resource "aws_cloudtrail" "main" {
  name = "main-${var.stage}"

  # The trail can't be created until after the bucket policy. Normally this means that
  # the depends_on meta-argument must be added to this resource block to configure an
  # explicit dependency on the bucket policy. But that's not required in this case
  # because the bucket is created by the baseline_s3_bucket module which already
  # configures an explicit dependency on the bucket policy when declaring the bucket_id
  # output.
  s3_bucket_name = module.log_baseline_s3_bucket["cloudtrail"].bucket_id

  is_organization_trail = true
  is_multi_region_trail = true

  # Make it possible to validate the integrity of log files
  enable_log_file_validation = true
}

# This policy document is passed into the baseline_s3_bucket module (via the
# extra_bucket_policy_documents variable) which creates the bucket policy for the
# CloudTrail log bucket by combining this policy document (which is specific to
# CloudTrail) with another policy document that's the same across all buckets.
data "aws_iam_policy_document" "cloudtrail_log_bucket_policy" {
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
      module.log_baseline_s3_bucket["cloudtrail"].unsafe_bucket_arn,
      "${module.log_baseline_s3_bucket["cloudtrail"].unsafe_bucket_arn}/*",
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
      values   = [var.mgmt_account_id]
    }
  }
}
