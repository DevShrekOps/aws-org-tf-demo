output "bucket_id" {
  description = "Name of this bucket."
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "ARN of this bucket."
  value       = aws_s3_bucket.main.arn
}
