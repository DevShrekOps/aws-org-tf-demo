# In the future, it might make sense to encrypt objects with a customer managed KMS key
# for enhanced access control & logging (or just to check a compliance box). But for now
# relying on the default SSE-S3 encryption is the simplest & cheapest approach.

resource "aws_s3_bucket" "main" {
  # Prefix with "devshrekops-" to reduce chance of naming collision with other customers
  # and include "demo-" to reduce chance of naming collision with other DevShrekOps
  # projects.
  bucket = "devshrekops-demo-${var.scope}-${var.stage}"
}

# Disable ACLs because they're an unnecessary, legacy form of access control, instead
# relying on bucket policies and IAM to govern access to the bucket.
resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Prevent a misconfiguration that could make the bucket publicly accessible. This
# probably isn't necessary since we enable this control at the account layer. At a
# minimum, it might check a compliance box.
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.baseline_bucket_policy.json
}

# Require requests to be encrypted in transit with TLS v1.3 or newer (to future-proof).
# In the future, it may become necessary to make the version configurable and/or lower
# the default to v1.2, depending on the frequency of compatibility issues.
data "aws_iam_policy_document" "baseline_bucket_policy" {
  statement {
    sid    = "RequireLatestTLS"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.main.arn,
      "${aws_s3_bucket.main.arn}/*",
    ]

    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = [1.3]
    }
  }
}
