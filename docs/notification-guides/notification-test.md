## Testing Your Notification Configuration

With your configuration in place, it's now time to test it.

First, we need to make sure that Voi Swarm picks up your changes to notification.yml.
To do this, rerun the installation script:

```bash
/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
```

After the script has run and applied changes to the environment, we need to send a test notification to make sure
everything is working as expected.

To do this, run the following command:

```bash
~/voi/bin/notification-test
```
