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

## -------------------------------------------------------------------------------------
## OPTIONAL INPUT VARIABLES
## -------------------------------------------------------------------------------------

variable "extra_bucket_policy_documents" {
  description = <<EOT
    Bucket policy documents to append to the baseline bucket policy. Documents must be
    in JSON format.
  EOT
  type        = list(string)
  nullable    = false
  default     = []
}
