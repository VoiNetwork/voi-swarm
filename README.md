# Docker Swarm Voi Participation Node Setup

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/ea47d627de494a92b25b97eb65930e85)](https://app.codacy.com/gh/VoiNetwork/docker-swarm/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)

## Prerequisites

- `curl`
- `apt-get`

If any package is not available on your system, or if you do not have permission to use said package, follow operating
system guidance on installation and setup.

## Supported Operating Systems and Compute Platforms

### Operating Systems

- Debian
- Ubuntu

### Compute Platforms

- arm64
- amd64 (x86_64)

## New to Voi

To set up a new Voi node, run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/VoiNetwork/docker-swarm/main/install.sh)"
```

## Using an Existing Account/Address with Mnemonic

If you have an existing account/address with a mnemonic that you want to use, set the VOINETWORK_IMPORT_ACCOUNT
environment variable to 1 and run the installation script:

```bash
export VOINETWORK_IMPORT_ACCOUNT=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/VoiNetwork/docker-swarm/main/install.sh)"
```

## Installing Without Wallet Setup

If you want to install without including wallet setup, set the VOINETWORK_SKIP_WALLET_SETUP environment variable to 1
and run the installation script:

```bash
export VOINETWORK_SKIP_WALLET_SETUP=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/VoiNetwork/docker-swarm/main/install.sh)"
```

## Updating Participation Key

If your Voi node's participation key is nearing its expiry date (less than 14 days left), you can renew it by running
the installation script again. This script is programmed to create new participation keys when the current ones are
close to expiring. So, to keep your Voi node active, make sure your participation key is up-to-date. If it's about to
expire, rerun the installation script to generate a new key.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/VoiNetwork/docker-swarm/main/install.sh)"
```

## Setting a Custom Telemetry Name

To set a custom telemetry name, set the VOINETWORK_TELEMETRY_NAME environment variable to your desired name:

```bash
export VOINETWORK_TELEMETRY_NAME="my_custom_telemetry_name"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/VoiNetwork/docker-swarm/main/install.sh)"
```

Custom telemetry name can be combined with other environment variables.

## Uninstalling

To uninstall, execute the following commands:

- Leave the Docker swarm with `docker swarm leave --force`
- Remove the `voi` directory with `rm -rf /voi/`
- Remove the `data` directory with `sudo rm -rf /var/lib/voi`

## Useful Scripts

This section provides a collection of useful scripts for managing your Voi participation node. These scripts are
designed to be executed within a running Docker container. They closely follow the commands outlined in the
[D13 guide](https://d13.co/posts/set-up-voi-participation-node/) for setting up a Voi participation node under Ubuntu 22.04.

### Creating a Node Wallet

Create a new wallet with the following command:

```bash
~/voi/bin/create-wallet <wallet_name>
```

### Creating an Account

Create a new account with the following command:

```bash
~/voi/bin/create-account
```

### Retrieving Account Mnemonic

Retrieve the mnemonic of an existing account with the following command:

```bash
~/voi/bin/get-account-mnemonic <account_address>
```

### Importing an Account

Import an existing account with the following command:

```bash
~/voi/bin/import-account
```

### Generating Participation Key

Generate a participation key for an existing account with the following command:

```bash
~/voi/bin/generate-participation-key <account_address>
```

### Checking Participation Status

Check the participation status of an existing account with the following command:

```bash
~/voi/bin/get-participation-status <account_address>
```

### Going Online

Bring an existing account online with the following command:

```bash
~/voi/bin/go-online <account_address>
```

### Going Offline

Take an existing account offline with the following command:

```bash
~/voi/bin/go-offline <account_address>
```

### Executing Goal Commands

Execute goal commands with the following command:

```bash
~/voi/bin/goal <goal_command>
```

### Opening a Bash Shell in the AVM Container

Open a bash shell in the AVM container with the following command:

```bash
~/voi/bin/start-shell
```

### Getting Basic Node Health

To retrieve basic health information about your node, execute the following command:

```bash
~/voi/bin/get-node-status
```

The `get-node-status` command performs checks using:

- `goal node status` to connect to the running daemon and retrieve basic node information
- `/health`: This API endpoint checks the reported health of the node. [REST API /health documentation](https://developer.algorand.org/docs/rest-apis/algod/#get-health).
- `/ready`: This API endpoint checks the reported readiness of the node and if fully caught up. [REST API /ready documentation](https://developer.algorand.org/docs/rest-apis/algod/#get-ready).

## Debugging

### Startup state for services in stack

`docker stack ps --no-trunc voinetwork`

### Replication state for services in stack

`docker service ls`

### Pull log files

`docker service logs voinetwork_algod`

### Inspect service

`docker inspect voinetwork_algod`

## TODO

- [ ] Add apprise / alarming on scaling events in docker-compose.yml
- [ ] Add script for participation key management
- [ ] Add mechanism for a user to specify notification mechanism for key expiration
