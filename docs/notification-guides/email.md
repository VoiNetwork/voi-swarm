# Email

!!! info
    Follow guidance on [enabling notifications](../../operating/setup-notifications/) first.

## What It Is?

Notifications can be sent via email.

## Supported Ways To Receive Notifications

- Email

## What To Know Before You Start

Email sending is done by using an existing email provider that offers SMTP services.
This is a simple and easy way to send notifications to your email address, but may require some setup.

If you own your own domain, and control DNS settings,
you can use a service such as [Amazon SES](amazon-ses.md) to send email in a cost-effective way.

If you do not own your own domain,
or are unable to control DNS settings, you can use a free email provider such as live.com to send email.
Some providers (e.g., Gmail)
have security mechanisms in place that may prevent you from easily sending email using SMTP.

Learn more at [Apprise Notify Email](https://github.com/caronc/apprise/wiki/Notify_email)

### Why Don't You Offer a Free Email Notification Service?

Collecting and storing email addresses, that would be associated with specific Voi accounts
would require us to comply with data protection laws, which would be a significant burden
for us to manage.
The current setup allows you to use your own email provider, and we do not have to manage any personal data.

## Using Live.com to Send Email

!!! note
      Full configuration options and capabilities are available via [Apprise](https://github.com/caronc/apprise/wiki/Notify_email)
        and may be required depending on your email provider and/or SMTP configuration.

1. Create a new email account used only for notifications. This is to ensure that your main email account is not compromised if the notification email account is compromised.
2. Configure the notification email account to forward emails to your main email account.
3. Set your notification email to have a strong password with no special characters. This is to ensure that the password can be used in the `notification.yml` file without needing to escape special characters.
4. Copy the example `notification.yml.example` file to the `notification.yml` file:

    ```bash
    cp ~/voi/docker/notification.yml.example ~/voi/docker/notification.yml
    ```

5. Update the **NOTIFICATION_URLS** value in `notification.yml` file with your Email mailto:// link

    ``` yaml
    NOTIFICATION_URLS="mailto:///example:mypassword@live.com?from=Voi%20Notification"
    ```

!!! tip
      If you want to use multiple notification mechanisms, separate them with a comma.
      For example, to use both Discord and Email for notification, you would set the **NOTIFICATION_URLS** value
      in the `notification.yml` file to:

       ```yaml
       NOTIFICATION_URLS="discord://<webhook_id>/<webhook_token>,mailto:///example:mypassword@live.com?from=Voi%20Notification"
       ```

--8<-- "notification-guides/notification-test.md"
