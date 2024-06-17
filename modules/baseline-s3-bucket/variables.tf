## -------------------------------------------------------------------------------------
## REQUIRED INPUT VARIABLES
## -------------------------------------------------------------------------------------

variable "stage" {
  description = "Deployment stage (e.g., dev or prod). Used in the bucket name."
  type        = string
  nullable    = false
}

variable "scope" {
  description = "Scope of what's stored in the bucket. Used in the bucket name."
  type        = string
  nullable    = false
}
