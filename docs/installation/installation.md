# Setting up a new Voi Node

## New to Voi

Use this method if you are new to Voi and want to set up a new node.
During the process, you will be asked for a few details to set up your node,
and where we have automated as much as possible.

To set up a new Voi node, run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
```

## Using an Existing Account/Address with Mnemonic

For installing with an existing account or mnemonic, use this method.
After installation, [update your name and GUID](../../updating/telemetry/#getting-your-telemetry-status)
for health rewards if setting up on a new server.

To import your account and set up a new Voi node, run the following command:

```bash
export VOINETWORK_IMPORT_ACCOUNT=1
/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
```

???+ info
    While the installation detects existing host-based setups (such as D13) on the same host
    and offers migration automatically,
    it is important to familiarize yourself with the [migration steps](../../migrating/), in particular,
    if you are [migrating from a different host](../../migrating/#installing-on-a-new-server).
