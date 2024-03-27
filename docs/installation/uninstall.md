# Uninstalling Voi

## Removing Your Installation

!!! danger
    Make sure to [keep your account mnemonics](../../cli-tools/#retrieving-account-mnemonic) in a safe place.
    If you lose it, you will lose access to your account, including any Voi and Via tokens you have.

To uninstall, execute the following commands:

- Leave the Swarm

    ```bash
    docker swarm leave --force
    ```

- Remove the **~/voi** directory

    ```bash
    rm -rf ~/voi/
    ```

- Remove the **/var/lib/voi** directory

    ```bash
    rm -rf /var/lib/voi
    ```
