{% docs usage_ping_mart %}

XF model to pull email lists from all our systems. This model provides four different kinds of contacts differentiated by the following columns:

- **is_account_billing_contact**: When `TRUE` represents the accounts billing contact.
- **is_gitlab_user_notification_contact**: When `TRUE` represents the gitlab user notification contact information.
- **is_gitlab_user_public_contact**: When `TRUE` represents the gitlab user public contact information.
- **is_sfdc_contact**: When `TRUE` represents the SFDC contacts associated with the account.

**Note** for `is_account_billing_contact` this model only includes accounts with an `active` rate plan with `recurring` charges.

{% enddocs %}
