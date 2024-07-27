output "full_admin_sso_perm_set_arn" {
  description = "ARN of the full-admin-access-<stage> SSO permission set."
  value       = aws_ssoadmin_permission_set.full_admin.arn
}

output "org_admins_sso_group_id" {
  description = "ID of the org-admins-<stage> SSO Group."
  value       = aws_identitystore_group.org_admins.group_id
}

output "sso_instance_arn" {
  description = "IAM Identity Center instance ARN."
  value       = local.sso_instance_arn
}

output "sso_identity_store_id" {
  description = "Identity Store ID of the IAM Identity Center instance."
  value       = local.sso_identity_store_id
}

output "sso_user_ids" {
  description = "Object of SSO users with username as key and user ID as value."
  value = {
    for sso_user in aws_identitystore_user.main : sso_user.user_name => sso_user.user_id
  }
}
