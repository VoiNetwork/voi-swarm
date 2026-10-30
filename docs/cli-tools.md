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
    including any Voi tokens you have. Here's how to [keep your seed phrase safe](https://coinmarketcap.com/academy/article/how-to-protect-your-seed-phrase).

### Importing an Account

Import an existing account with the following command:

```bash
~/voi/bin/import-account
```

!!! note
    Use this command to import wallets created on a different terminal or from third-party wallets, such as Kibisis or A-Wallet.

### Generating Participation Key

Generate a participation key for an existing account with the following command:

```bash
~/voi/bin/generate-participation-key <account_address>
```

After generation, you will need to take the account online with the new key.

!!! note
    We recommend rerunning the installer with `/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"`, this process will automatically take care of generation as well as taking the new key online.

### Checking Participation Status

Check the participation status of an existing account with the following command:

```bash
~/voi/bin/get-participation-status <account_address>
```

### Regenerating Participation Key

After 2 million blocks or in an estimated 60 days, you will need
to regenerate a new participation key with the following command:

```bash
/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
```

### Going Online

Bring an existing account online with the following command:

```bash
~/voi/bin/go-online <account_address>
```

### Opting In to Proposer Rewards

Accounts with a balance between 30,000 and 70,000,000 Voi can earn rewards for proposing blocks.
To be eligible, an account pays a one-time 2 Voi fee when registering its participation key.
Opt in an online account with the following command:

```bash
~/voi/bin/enable-rewards <account_address>
```

This registers your current participation key again with the 2 Voi fee, without generating a new key.
If the account's balance is outside the eligible range, you are warned before anything is sent.
Rewards start a few hundred blocks after opting in.

!!! note
    An account that is suspended for missing its proposals loses its eligibility, and has to opt in again.

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
