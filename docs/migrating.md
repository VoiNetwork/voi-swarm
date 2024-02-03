# Migrating to Voi Swarm

## From D13 based setups

Install Voi Swarm on your server by importing your existing wallet using your mnemonic:

```bash
export VOINETWORK_IMPORT_ACCOUNT=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/VoiNetwork/voi-swarm/main/install.sh)"
```

=== "Installing on same server"

    To migrate your setup on an existing server you must first install Voi Swarn on your server using the
    [installation instructions](../installation/installation/#using-an-existing-accountaddress-with-mnemonic), after this
    you can migrate your existing setup by running this command:


    ```bash
    ~/voi/bin/migrate-from-d13-setup
    ```

    This command will do the following steps for you:

    1. Duplicate telemetry settings, including existing telemetry name and GUID, without affecting rewards.
    2. Stop the host-based Voi service
    3. Restart Voi Swarm

=== "Installing on a new server"

    To migrate your setup to a new server you must first install Voi Swarm on the new server using the
    [installation instructions](../installation/installation/#using-an-existing-accountaddress-with-mnemonic), after this
    you can migrate your existing setup by following these steps:

    1. Run the following command on the old server to get the telemetry name and GUID:

        ```bash
        sudo ALGORAND_DATA=/var/lib/algorand diagcfg telemetry status
        ```
    2. Copy the telemetry name and GUID to the new server.
    3. Run the following command on the new server to set the telemetry name and GUID:

        ```bash
        ~/voi/bin/set-telemetry-name <telemetry-name> <telemetry-guid>
        ```
