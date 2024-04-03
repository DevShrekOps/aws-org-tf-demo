# mgmt-prod

Terraform root module for the production management account.

## Manual Action Log

Chronological list of manual actions performed in this account.

1. Created this AWS account through the AWS website. Set the email address to **devshrekops+demo-mgmt-prod@gmail.com** and the account name to **demo-mgmt-prod**. It's probably best not to store your AWS account's email address in a public git repo (if for no reason other than some extra security through obscurity) but this is a throwaway demo account. It's also probably best to use different email addresses for prod & dev (not just different subaddresses) so that different people can be granted access to each email address based on your organization's requirements. The account came with two IAM service-linked roles, one for Support and one for Trusted Advisor.
2. Logged into this AWS account as the root user and assigned it a virtual MFA device using Google Authenticator on my phone. It's probably best to instead use a hardware MFA device for the root user of your management account (especially a prod one) but this is a throwaway demo account.
