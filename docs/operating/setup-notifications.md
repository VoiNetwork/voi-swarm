# Setup notifications

## Enabling Notifications

Voi Swarm offers the ability to receive notifications when the participation key is about to expire, helping you to keep
your node healthy and active.

## Get Started

The notification.yml file is an example file that you can use to set up notifications.
Start by copying the example `~/voi/docker/notification.yml.example` file to the `~/voi/docker` directory
without the .example extension

```bash
cp ~/voi/docker/notification.yml.example ~/voi/docker/notification.yml
```

## Adding Your Notification Choices

Update the notification.yml file with your preferred notification mechanism by updating the **NOTIFICATION_URLS**
environment variable. The notification mechanism can be a webhook, email, push, or any other notification mechanism that
is available via [Apprise notifications](https://github.com/caronc/apprise?tab=readme-ov-file#supported-notifications)

If you want to use multiple mechanisms, separate them with a comma. For example, to use both Discord and Pushbullet for
notification, you would set the **NOTIFICATION_URLS** value in the **notification.yml** file to:

```yaml
NOTIFICATION_URLS="discord://<webhook_id>/<webhook_token>,pbul://<access_token>"
```

## Updating Participation Key Checker Schedule

To modify the participation key notification schedule, adjust the labels in the notification.yml file.

| Label                    | Description            |
|--------------------------|------------------------|
| `swarm.cronjob.schedule` | `0 16 * * *` (default) |

This is by default set to run daily at 4 PM UTC. Adjust this to your preferred time, accounting for your
timezones UTC offset. Use a resource like [dateful.com](https://dateful.com/time-zone-converter) for timezone conversion.

The format of the schedule is following the [CRON format](https://pkg.go.dev/github.com/robfig/cron#hdr-CRON_Expression_Format).

## Applying Notification Configuration to the Stack

To apply your notification configuration to the stack, rerun the installation script:

```bash
/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
```

## Testing Your Notification Configuration

To test your notification configuration, you can manually trigger the notification service by running the following command:

```bash
~/voi/bin/notification-test
```
