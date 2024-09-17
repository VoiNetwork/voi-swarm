# Migrating to a New Network

Migrating to a new network is straightforward. Run the installation script with the **VOINETWORK_NETWORK** variable set to the
name of the network you want to join.

During migration, you will be prompted to take existing accounts offline.
New participation keys will be generated, allowing you to go online on the new network.

## Migrating to Mainnet

To migrate to Mainnet, execute the following command:

```bash
export VOINETWORK_NETWORK=mainnet
/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
```

!!! note
    If you run a relay server and previously had **ufw** enabled you may need to delete a firewall rule by running `sudo delete ufw allow from 85.10.250.105 to any port 9100`

## Migrating to Testnet

To migrate to Testnet, execute the following command:

```bash
export VOINETWORK_NETWORK=testnet
/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
```
