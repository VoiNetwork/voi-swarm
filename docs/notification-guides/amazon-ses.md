# Amazon SES

!!! info
    Follow guidance on [enabling notifications](../../operating/setup-notifications/) first.

## What It Is?

[Amazon SES](https://aws.amazon.com/ses/) is a cost-effective email service that offers email sending,
at a cost of $0.10 per 1,000 emails.
No monthly fees or upfront commitments are required.

## Supported Ways To Receive Notifications

- Email

## What To Know Before You Start

A solid understanding of DNS and Amazon AWS is required, including knowledge on how to secure your AWS account.

## Configuring Amazon SES

!!! info
    Full configuration options and capabilities are available via [Apprise](https://github.com/caronc/apprise/wiki/Notify_ses)

1. Create an IAM user that has access to SES. The user should have a programmatic access key and secret key.
2. Attach the [following policy](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/control-user-access.html) to the user:
    ```json
       {
         "Version":"2012-10-17",
         "Statement":[
           {
             "Effect":"Allow",
             "Action":[
               "ses:SendEmail",
               "ses:SendRawEmail"
             ],
             "Resource":"*"
           }
         ]
       }
    ```
3. Set up Amazon SES for your domain, which includes domain verification and DKIM record setup.
   DKIM verification is automated with Route 53.
For other DNS providers, manually add the necessary DNS CNAME records for DKIM verification.
4. Verify your domain to start sending emails. This can take from minutes and up to 72 hours.
5. Copy the example `notification.yml.example` file to the `notification.yml` file:

    ```bash
    cp ~/voi/docker/notification.yml.example ~/voi/docker/notification.yml
    ```

6. Update the **NOTIFICATION_URLS** value in `notification.yml` file with your ses:// link

    ``` yaml
    NOTIFICATION_URLS="ses://<sender_account>@<sender_domain>/<access_key>/access_secret>/<region>/<recipient_email>/?from=<sender_name>"
    ```

    If the sender name contains whitespaces make sure you substitute them with `%20` in the `from` parameter.

!!! tip
    If you want to use multiple notification mechanisms, separate them with a comma.
    For example, to use both Discord and Email for notification, you would set the **NOTIFICATION_URLS** value
    in the `notification.yml` file to:

       ```yaml
       NOTIFICATION_URLS="discord://<webhook_id>/<webhook_token>,ses://<sender_account>@<sender_domain>/<access_key>/access_secret>/<region>/<recipient_email>/?from=<sender_name>"
       ```

--8<-- "notification-guides/notification-test.md"
