## -------------------------------------------------------------------------------------
## REQUIRED INPUT VARIABLES
## -------------------------------------------------------------------------------------

variable "stage" {
  description = "Deployment stage (e.g., dev or prod)."
  type        = string
  nullable    = false
}

variable "mgmt_account_id" {
  description = "ID of the management account for this stage."
  type        = string
  nullable    = false
}
