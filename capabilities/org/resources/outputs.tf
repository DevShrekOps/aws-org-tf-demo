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

output "org_root_id" {
  description = "ID of the org's root."
  value       = aws_organizations_organization.main.roots[0].id
}

output "ou_ids" {
  description = "IDs of the OUs in the org."
  value = {
    "active" : aws_organizations_organizational_unit.active.id
    "closed" : aws_organizations_organizational_unit.closed.id
  }
}

output "scp_ids" {
  description = "IDs of the SCPs in the org."
  value = {
    "baseline_guardrails" : aws_organizations_policy.baseline_guardrails.id
    "deny_all" : aws_organizations_policy.deny_all.id
  }
}
