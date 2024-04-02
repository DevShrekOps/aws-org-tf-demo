## -------------------------------------------------------------------------------------
## REQUIRED INPUT VARIABLES
## -------------------------------------------------------------------------------------

variable "stage" {
  description = "Deployment stage (e.g., dev or prod)."
  type        = string
  nullable    = false
}

## -------------------------------------------------------------------------------------
## OPTIONAL INPUT VARIABLES
## -------------------------------------------------------------------------------------

variable "sso_org_admins" {
  description = <<EOT
    Usernames of SSO users to add to org admins group in IAM Identity Center. All users
    must be declared in the `sso_users` variable.
  EOT
  type        = list(string)
  default     = []
  nullable    = false
}

variable "sso_users" {
  description = "SSO users to create in IAM Identity Center."
  type = list(object({
    username     = string
    display_name = string
    email        = string
    first_name   = string
    last_name    = string
  }))
  default  = []
  nullable = false
}
