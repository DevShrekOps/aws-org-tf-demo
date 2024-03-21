output "org_accounts" {
  description = "Metadata of all accounts in the organization."
  value       = aws_organizations_organization.main.accounts
}

output "org_admins_sso_group_id" {
  description = "ID of the org-admins-<stage> SSO Group."
  value       = aws_identitystore_group.org_admins.group_id
}

output "org_id" {
  description = "Organization ID."
  value       = aws_organizations_organization.main.id
}

output "org_roots" {
  description = "Organization roots."
  value       = aws_organizations_organization.main.roots
}

output "sso_instance_arn" {
  description = "IAM Identity Center instance ARN."
  value       = local.sso_instance_arn
}

output "sso_identity_store_id" {
  description = "Identity Store ID of the IAM Identity Center instance."
  value       = local.sso_identity_store_id
}
