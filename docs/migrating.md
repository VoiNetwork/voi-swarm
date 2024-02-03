# Migrating to Voi Swarm

## D13 based setups

=== "Installing on same server"

    To help migrate from D13 based setups, there's a migration command available. This command will

    1. Duplicate telemetry settings, including existing telemetry name and GUID, without affecting rewards.
    2. Stop the host-based Voi service
    3. Restart Voi Swarm

    To run this command, you must install Voi Swarm first. Then run the following command:

    ```bash
    ~/voi/bin/migrate-from-d13-setup
    ```

=== "Installing on a new server"

    To migrate to a new server, you must first install Voi Swarm on the new server.

    1. Run the following command on the old server to get the telemetry name and GUID:

        ```bash
        sudo ALGORAND_DATA=/var/lib/algorand diagcfg telemetry status
        ```
    2. Copy the telemetry name and GUID to the new server.
    3. Run the following command on the new server to set the telemetry name and GUID:

        ```bash
        ~/voi/bin/set-telemetry-name <telemetry-name> <telemetry-guid>
        ```
