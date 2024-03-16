# mgmt-dev

Terraform root module for the development management account.

## Manual Action Log

Chronological list of manual actions performed in this account.

1. Created this AWS account through the AWS website. Set the email address to **devshrekops+demo-mgmt-dev@gmail.com**, the account name to **demo-mgmt-dev**, and the credit card number to **just kidding**. It's probably best not to store your AWS account's email address in a public git repo (if for no reason other than some extra security through obscurity) but this is a throwaway demo account. The account came with two IAM service-linked roles, one for Support and one for Trusted Advisor.
2. Logged into this AWS account as the root user and assigned it a virtual MFA device using Google Authenticator on my phone. It's probably best to instead use a hardware MFA device for the root user of your management account (even a dev one) but this is a throwaway demo account.
