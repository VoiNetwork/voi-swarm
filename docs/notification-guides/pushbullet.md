# Pushbullet

!!! info
    Follow guidance on [enabling notifications](../../operating/setup-notifications/) first.

## What It Is?

[Pushbullet](https://www.pushbullet.com) is a free and easy-to-use notification service that can be used to send notifications to your phone, tablet, or computer.

## Supported Ways To Receive Notifications

- Push notifications to your phone, tablet, or computer

## How To Set Up Pushbullet

### Get Started

!!! info inline end
    Full configuration options and capabilities are available via [Apprise](https://github.com/caronc/apprise/wiki/Notify_pushbullet)

1. Create a Pushbullet account if you don't already have one. Sign up links are on their [homepage](https://www.pushbullet.com).
2. Install the Pushbullet app on your phone, tablet, or computer.
3. Follow the instructions to set up the app on your device.
4. Go to [https://www.pushbullet.com/#settings](https://www.pushbullet.com/#settings) and create an access token.
5. Copy the access token and store securely.
6. Copy the example `notification.yml.example` file to the `notification.yml` file:

    ```bash
    cp ~/voi/docker/notification.yml.example ~/voi/docker/notification.yml
    ```

7. Update the **NOTIFICATION_URLS** value in `notification.yml` file with your Pushbullet access token:

    ```yaml
    NOTIFICATION_URLS="pbul://<access_token>"
    ```

!!! tip
    If you want to use multiple notification mechanisms, separate them with a comma.
    For example, to use both Discord and Pushbullet for notification, you would set the **NOTIFICATION_URLS** value
    in the `notification.yml` file to:
    ```yaml
    NOTIFICATION_URLS="discord://<webhook_id>/<webhook_token>,pbul://<access_token>"
    ```

--8<-- "notification-guides/notification-test.md"
