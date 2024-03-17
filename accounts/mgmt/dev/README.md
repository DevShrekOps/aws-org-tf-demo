# mgmt-dev

Terraform root module for the development management account.

## Manual Action Log

Chronological list of manual actions performed in this account.

1. Created this AWS account through the AWS website. Set the email address to **devshrekops+demo-mgmt-dev@gmail.com**, the account name to **demo-mgmt-dev**, and the credit card number to **just kidding**. It's probably best not to store your AWS account's email address in a public git repo (if for no reason other than some extra security through obscurity) but this is a throwaway demo account. The account came with two IAM service-linked roles, one for Support and one for Trusted Advisor.
2. Logged into this AWS account as the root user and assigned it a virtual MFA device using Google Authenticator on my phone. It's probably best to instead use a hardware MFA device for the root user of your management account (even a dev one) but this is a throwaway demo account.
3. As the root user in the AWS console, enabled IAM Identity Center. Selected the option to **Enable with AWS Organizations**. This resulted in creation of an Identity Center instance with Identity Center directory as the identity source, an organization with all features and Identity Center service integration enabled, and two IAM service-linked roles, one for Organizations and one for SSO (aka Identity Center). At a minimum, I'll import the organization into this module in a future commit. If you're creating an AWS org in support of a company with an existing identity provider, then it's probably best to integrate Identity Center with that identity provider, but for this demo I'll be sticking with the native identity store.
4. As the root user in the AWS console, set the Identity Center instance name to **demo-sso-dev** and standard authentication to **Send email OTP**.
5. As the root user in the AWS console, created a group named **org-admins-dev** in Identity Center. Set the description to **Grants full admin access to all accounts in the dev org**. I'll import this group into this module in a future commit.
6. As the root user in the AWS console, created a permission set named **full-admin-access-dev** in Identity Center. Selected **Predefined permission set** and the **AdministratorAccess** AWS managed policy. Set description to **Grants full admin access to a dev account**. Set session duration to **12 hours**. I'll import this permission set into this module in a future commit. I'll probably use a shorter session duration in the prod Identity Center instance but in dev I want to minimize how often reauthentication is required, at least during early stages of development.
