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
