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

## Setting a Custom Telemetry Name as Part of Installation (advanced)

!!! info
    This is an advanced feature intended for automation, and is **not required** before telemetry can be used.

During installation, you will automatically be prompted to set a custom telemetry name if not set already.
If you prefer to set a name through the environment, you can do so by setting the
**VOINETWORK_TELEMETRY_NAME** environment variable to your desired name.

This would typically be done if you are automating the installation process.

```bash
export VOINETWORK_TELEMETRY_NAME="my_custom_telemetry_name"
/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
```

A custom telemetry name can be combined with other environment variables.
