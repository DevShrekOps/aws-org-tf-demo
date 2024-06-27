output "bucket_id" {
  description = <<EOT
    Name of this bucket. Safe to reference in resource declarations that depend on the
    bucket policy.
  EOT

  value = aws_s3_bucket.main.id

  # Ensure resources that reference this output are created after the bucket policy
  depends_on = [aws_s3_bucket_policy.main]
}

output "bucket_arn" {
  description = <<EOT
    ARN of this bucket. Safe to reference in resource declarations that depend on the
    bucket policy.
  EOT

  value = aws_s3_bucket.main.arn

  # Ensure resources that reference this output are created after the bucket policy
  depends_on = [aws_s3_bucket_policy.main]
}

output "unsafe_bucket_arn" {
  description = <<EOT
    ARN of this bucket. Not safe to reference in resource declarations that depend on
    the bucket policy.
  EOT

  value = aws_s3_bucket.main.arn
}
