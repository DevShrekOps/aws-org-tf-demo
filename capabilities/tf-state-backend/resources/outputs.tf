output "state_baseline_s3_bucket_outputs" {
  description = "All outputs from the state_baseline_s3_bucket module."
  value       = module.state_baseline_s3_bucket
}

output "state_locks_dynamodb_table_arn" {
  description = "ARN of the state locks DynamoDB table."
  value       = aws_dynamodb_table.state_locks.arn
}

output "state_manager_role_arn" {
  description = "ARN of the state manager IAM role."
  value       = aws_iam_role.state_manager.arn
}
