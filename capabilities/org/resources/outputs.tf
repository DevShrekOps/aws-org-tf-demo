output "org_accounts" {
  description = "Metadata of all accounts in the organization."
  # Don't use aws_organizations_organization.main.accounts for this because it doesn't
  # update when a new account is created until the next `terraform apply` due to lack
  # of a dependency on aws_organizations_account.main. It feels backward to add such a
  # dependency.
  value = {
    for account_key, account in aws_organizations_account.main : account_key => {
      arn   = account.arn,
      email = account.email,
      id    = account.id,
      name  = account.name,
    }
  }
}

output "org_id" {
  description = "ID of the org."
  value       = aws_organizations_organization.main.id
}

output "org_roots" {
  description = "Roots of the org."
  value       = aws_organizations_organization.main.roots
}
