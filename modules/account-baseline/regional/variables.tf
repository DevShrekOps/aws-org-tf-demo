## -------------------------------------------------------------------------------------
## REQUIRED INPUT VARIABLES
## -------------------------------------------------------------------------------------

variable "stage" {
  description = "Deployment stage (e.g., dev or prod)."
  type        = string
  nullable    = false
}

variable "config_svc_role_arn" {
  description = "ARN of the IAM service-linked role for Config in this account."
  type        = string
  nullable    = false
}
