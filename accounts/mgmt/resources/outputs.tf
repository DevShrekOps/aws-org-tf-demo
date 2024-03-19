output "org_accounts" {
  description = "Metadata of all accounts in the organization."
  value       = aws_organizations_organization.main.accounts
}

output "org_id" {
  description = "Organization ID."
  value       = aws_organizations_organization.main.id
}

output "org_roots" {
  description = "Organization roots."
  value       = aws_organizations_organization.main.roots
}
