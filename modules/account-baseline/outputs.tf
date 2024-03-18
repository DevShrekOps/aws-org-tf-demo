output "account_alias" {
  description = "Globally unique alias of this account."
  value       = aws_iam_account_alias.main.account_alias
}
