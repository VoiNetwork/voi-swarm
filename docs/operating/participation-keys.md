# Keep Your Participation Keys Up-to-Date

To participate in the Voi network, you need to keep your participation key up-to-date.
The participation key is used to sign blocks and participate in the consensus process.
If your participation key is not up-to-date, your node will not be able to participate in the consensus process.

To keep your participation key up-to-date, you can run the installation script again. The script will create a new key
if your current key is expected to expire within the next 14 days.

```bash
/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
```

!!! tip
    Setup expiration notifications to receive a reminder when your participation key is about to expire.
    [Learn more](./setup-notifications.md)
