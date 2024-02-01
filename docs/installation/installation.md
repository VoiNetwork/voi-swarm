# Setting up a new Voi Node

## New to Voi

!!! tip
    Start here if you are new to Voi and want to set up a new Voi node.
    During the process you will be asked for a few details to set up your node, and where we have automated as much as possible.

To set up a new Voi node, run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/VoiNetwork/voi-swarm/main/install.sh)"
```

## Using an Existing Account/Address with Mnemonic

If you have an existing account/address with a mnemonic that you want to use, set the **VOINETWORK_IMPORT_ACCOUNT**
environment variable to **1** and run the installation script:

```bash
export VOINETWORK_IMPORT_ACCOUNT=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/VoiNetwork/voi-swarm/main/install.sh)"
```

## Installing Without Wallet Setup

If you want to install without including wallet setup, set the **VOINETWORK_SKIP_WALLET_SETUP** environment variable to
**1** and run the installation script:

```bash
export VOINETWORK_SKIP_WALLET_SETUP=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/VoiNetwork/voi-swarm/main/install.sh)"
```

## Setting a Custom Telemetry Name as part of installation (advanced)

!!! info
    This is an advanced feature and is not required to have telemetry configured.

During installation, you will be prompted to set a custom telemetry name, if however you prefer to set a name through
the environment you can do so by setting the **VOINETWORK_TELEMETRY_NAME** environment variable to your desired name.

This would typically be done if you are automating the installation process.

```bash
export VOINETWORK_TELEMETRY_NAME="my_custom_telemetry_name"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/VoiNetwork/voi-swarm/main/install.sh)"
```

A custom telemetry name can be combined with other environment variables.
