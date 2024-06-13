## -------------------------------------------------------------------------------------
## REQUIRED INPUT VARIABLES
## -------------------------------------------------------------------------------------

variable "stage" {
  description = "Deployment stage (e.g., dev or prod)."
  type        = string
  nullable    = false
}

variable "account_key" {
  description = "Account key (e.g., mgmt, sec, or net)."
  type        = string
  nullable    = false
}
