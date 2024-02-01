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

## Testing Your Notification Configuration

With your configuration in place it's now time to test it.

First we need to make sure that your changes to notification.yml is picked up by the stack.
To do this, rerun the installation script:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/VoiNetwork/voi-swarm/main/install.sh)"
```

After the script has run and applied changes to the environment we need to send a test notification to make sure
everything is working as expected.

To do this, run the following command:

```bash
~/voi/bin/notification-test
```
