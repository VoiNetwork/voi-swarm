# Voi Swarm

## About

This repository contains the installation script and configuration files for setting up a Voi participation node on a
Linux system. 

Success criteria for the installation script are:

    Focus on providing a good user experience.
    Provide a simple and easy way to onboard new participants.
    Offer easy ways for users to operate and maintain their nodes.

To achieve the above the package is an opinionated way to join the network, and may thus not be suitable for 
all use cases.

## Documentation

Documentation can be found on [https://voinetwork.github.io/voi-swarm/](https://voinetwork.github.io/voi-swarm/)

## Contributing

Contributions are welcome! Please join the [Voi Network Discord server](https://discord.com/invite/vnFbrJrHeW) to discuss
with other community members and contributors. You can also open an issue or a pull request on GitHub.

## License

AGPL-3.0. See [LICENSE](LICENSE) for more information.




## Updating Your Participation Key

If your Voi node's participation key is nearing its expiry date (less than 14 days left), you can renew it by running
the installation script again. This script is programmed to create new participation keys when the current ones are
close to expiring. So, to keep your Voi node active, make sure your participation key is up-to-date. If it's about to
expire, rerun the installation script to generate a new key.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/VoiNetwork/voi-swarm/main/install.sh)"
```


