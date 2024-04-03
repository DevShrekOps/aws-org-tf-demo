# mgmt-prod

Terraform root module for the production management account.

## Manual Action Log

Chronological list of manual actions performed in this account.

1. Created this AWS account through the AWS website. Set the email address to **devshrekops+demo-mgmt-prod@gmail.com** and the account name to **demo-mgmt-prod**. It's probably best not to store your AWS account's email address in a public git repo (if for no reason other than some extra security through obscurity) but this is a throwaway demo account. It's also probably best to use different email addresses for prod & dev (not just different subaddresses) so that different people can be granted access to each email address based on your organization's requirements. The account came with two IAM service-linked roles, one for Support and one for Trusted Advisor.
2. Logged into this AWS account as the root user and assigned it a virtual MFA device using Google Authenticator on my phone. It's probably best to instead use a hardware MFA device for the root user of your management account (especially a prod one) but this is a throwaway demo account.
3. As the root user in the AWS console, enabled IAM Identity Center. Selected the option to **Enable with AWS Organizations**. This resulted in creation of an Identity Center instance with Identity Center directory as the identity source, an organization with all features and Identity Center service integration enabled, and two IAM service-linked roles, one for Organizations and one for SSO (aka Identity Center). I'll import the org into this module in a future commit. However, I won't import the Identity Store instance due to there not being an associated resource in the Terraform AWS provider. If you're creating an AWS org in support of a company with an existing identity provider, then it's probably best to integrate Identity Center with that identity provider, but for this demo I'll be sticking with the native identity store.
4. As the root user in the AWS console, set the Identity Center instance name to **demo-sso-prod** and standard authentication to **Send email OTP**.