# Installation - Advanced

This page contains advanced installation instructions for Voi Network.
Most users should use the [standard installation method](./installation.md).

## Installing Without Wallet Setup (advanced)

!!! warning
    For separate wallet management, install Voi without wallet setup.
    This advanced feature is not recommended for most users.
    Instead, opt for new user setup or existing account import.

If you want to install without including wallet setup, set the **VOINETWORK_SKIP_WALLET_SETUP** environment variable to
**1** and run the installation script:

```bash
export VOINETWORK_SKIP_WALLET_SETUP=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/VoiNetwork/voi-swarm/main/install.sh)"
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
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/VoiNetwork/voi-swarm/main/install.sh)"
```

A custom telemetry name can be combined with other environment variables.
