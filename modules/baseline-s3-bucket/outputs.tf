output "bucket_id" {
  description = "Name of this bucket."
  value       = aws_s3_bucket.main.id

  # Ensure calling modules wait for the bucket's policy to be set before using the
  # bucket so that resource declarations that depend on the bucket policy don't fail.
  depends_on = [aws_s3_bucket_policy.main]
}

output "bucket_arn" {
  description = "ARN of this bucket."
  value       = aws_s3_bucket.main.arn

  depends_on = [aws_s3_bucket_policy.main] # See comment in bucket_id output
}
