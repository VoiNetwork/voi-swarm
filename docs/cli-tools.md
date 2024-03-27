# CLI Tools

## Creating a Node Wallet

Create a new wallet with the following command:

```bash
~/voi/bin/create-wallet <wallet_name>
```

## Creating an Account

Create a new account with the following command:

```bash
~/voi/bin/create-account
```

### Retrieving Account Mnemonic

Retrieve the mnemonic of an existing account with the following command:

```bash
~/voi/bin/get-account-mnemonic <account_address>
```

!!! warning
    Remember to save or write down the 25-word seed phrase that shows up. If you lose it, you will lose access to your account,
    including any Voi and Via tokens you have. Here's how to [keep your seed phrase safe](https://coinmarketcap.com/academy/article/how-to-protect-your-seed-phrase).

### Importing an Account

Import an existing account with the following command:

```bash
~/voi/bin/import-account
```

!!! note
    This is for if you made a wallet on a different terminal or a 3rd party wallet provider. *i.e Kibisi or A-Wallet*

### Generating Participation Key

Generate a participation key for an existing account with the following command:

```bash
~/voi/bin/generate-participation-key <account_address>
```

!!! note
    Your participation key will expire in an estimated 60 days and will need to be regenerated.

### Checking Participation Status

Check the participation status of an existing account with the following command:

```bash
~/voi/bin/get-participation-status <account_address>
```

### Regenerating Participation Key

After 2 million blocks or in an estimated 60 days, you will need
to regenerate a new participation key with the following command:

```bash
`/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"`
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

### Getting Node Health

To retrieve health information about your node, execute the following command:

```bash
~/voi/bin/get-node-status
```

The `get-node-status` command prints out the following information

- Running Voi Swarm image identifier
- AVM version
- Node health status
    - High-level service status
    - Health status and if service is running
    - If the node is fully caught up with the chain
- Account status
    - Address
    - Balance
    - Participation key status
- Telemetry status
    - Enablement
    - Name
    - Short GUID

### Set Telemetry Name and GUID

To set telemetry name or to opt-out, execute the following command:

```bash
~/voi/bin/set-telemetry-name
```

To set telemetry name and GUID, execute the following command:

```bash
~/voi/bin/set-telemetry-name <telemetry_name> <telemetry_guid>
```

### Get Telemetry Status

To get status of your telemetry including enablement, name, and GUID, execute the following command:

```bash
~/voi/bin/get-telemetry-status
```
