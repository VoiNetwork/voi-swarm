# Setting up a new Voi Node

## New to Voi

Use this method if you are new to Voi and want to set up a new node.
During the process, you will be asked for a few details to set up your node,
and where we have automated as much as possible.

To set up a new Voi node, run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
```

!!! tip
    If you are looking to get Voi, you can buy them on centralized exchanges or use a decentralized exchange.
    Check out [ways to acquire Voi](../../getting-started/setup-account/#adding-voi-to-your-account) for more information.

## Using an Existing Account/Address with Mnemonic

For installing with an existing account or mnemonic, use the following command:

```bash
export VOINETWORK_IMPORT_ACCOUNT=1
/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
```
