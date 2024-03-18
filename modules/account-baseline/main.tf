## -------------------------------------------------------------------------------------
## ACCOUNT ALIAS
## -------------------------------------------------------------------------------------

# Prefix with "devshrekops-" to reduce chance of naming collision with other customers
# and include "demo-" to reduce chance of naming collision with other DevShrekOps
# projects.
resource "aws_iam_account_alias" "main" {
  account_alias = "devshrekops-demo-${var.account_type}-${var.stage}"
}
