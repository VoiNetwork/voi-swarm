# Installation - Advanced

This page contains advanced installation instructions for Voi Network.
Most users should use the [standard installation method](./installation.md).

## Installing Without Wallet Setup (advanced)

!!! warning
    For separate wallet management, install Voi without the wallet setup.
    This is an advanced feature and not suggested for most users.
    New user setup or importing an existing account is recommended.

If you want
to install Voi without setting up a wallet, and where you manage your keys offline or on
other systems, use the **VOINETWORK_SKIP_WALLET_SETUP** environment variable.

To skip wallet setup, run the following command:

```bash
export VOINETWORK_SKIP_WALLET_SETUP=1
/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
```

## Joining a Specific Network (advanced)

Voi Swarm supports joining the `mainnet`, `betanet`, or `testnet-v1.1` networks.
To specify a network during installation, set the **VOINETWORK_NETWORK** environment variable:

```bash
export VOINETWORK_NETWORK=testnet-v1.1
/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
```

When joining a new network, you will be prompted to take existing accounts offline.
New participation keys will then be generated allowing you to go online on the new network.
