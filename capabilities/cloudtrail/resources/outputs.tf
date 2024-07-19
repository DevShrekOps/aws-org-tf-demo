output "cloudtrail_arn" {
  description = "ARN of the CloudTrail."
  value       = aws_cloudtrail.main.arn
}

output "baseline_s3_bucket_outputs" {
  description = "All outputs from the baseline_s3_bucket module."
  value       = module.baseline_s3_bucket
}
