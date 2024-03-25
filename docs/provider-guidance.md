# Provider Guidance

This guidance covers basic steps that are typical for smaller cloud / VPS providers.
It is not exhaustive, and you should consult your provider's documentation for more detailed information.

## Before You Start
Before choosing a provider,
it is [important to understand the system requirements](../installation/system-requirements/) as they
will help you make the best decision for your node.

## Steps to Follow

1. **Create SSH keys**: This will authenticate you with your server.
   Some providers allow you to upload your public key for secure, passwordless access.
2. **Create a new server**: Spin up a new server with your chosen operating system. The community frequently uses Ubuntu 22.04 LTS.
3. **Secure your server**: Follow best practices for  permissions, software updates and firewalls.
4. **Install Voi Swarm**: [Follow the installation guide](../installation/installation/)

Step-by-step guides for some popular providers are provided below.

=== "Contabo"

      1. You will need to [generate an SSH key](https://contabo.com/blog/how-to-use-ssh-keys-with-your-server/).
      2. [Install a new server](https://help.contabo.com/support/solutions/articles/103000271913-how-do-i-install-my-contabo-server-) in Contabo using Ubuntu 22.04 LTS.
      3. You will need to [secure your server](https://contabo.com/blog/best-practices-for-securing-remote-connections-to-your-vps/).
      4. Finally, you will need to [install Voi Swarm](https://voinetwork.github.io/voi-swarm/installation/installation/).

=== "Hetzner"

      1. [Create an SSH key](https://community.hetzner.com/tutorials/howto-ssh-key) if needed. You can use an existing key during server creation at Hetzner by uploading the public key in their console.
      2. [Install a new server](https://docs.hetzner.com/cloud/servers/getting-started/creating-a-server/) in Hetzner using Ubuntu 22.04 LTS.
      3. You will need to [secure your server](https://community.hetzner.com/tutorials/securing-ssh).
      4. Finally, you will need to [install Voi Swarm](https://voinetwork.github.io/voi-swarm/installation/installation/).

=== "Melbicome"

      1. You will need to [generate an SSH key](https://webdock.io/en/docs/webdock-control-panel/shell-users-and-sudo/set-up-an-ssh-key).
      2. [Install a new server](https://www.melbicom.net/virtualserver/) in Melbicom using Ubuntu 22.04 LTS.
      3. You will need to [secure your server](https://www.liquidweb.com/blog/secure-server/).
      4. Finally, you will need to [install Voi Swarm](https://voinetwork.github.io/voi-swarm/installation/installation/).

=== "OVHcloud"

      1. You will need to [generate an SSH keys](https://help.ovhcloud.com/csm/en-ca-dedicated-servers-creating-ssh-keys?id=kb_article_view&sysparm_article=KB0043376).
      2. [Install a new server](https://help.ovhcloud.com/csm/en-gb-dedicated-servers-getting-started-dedicated-server?id=kb_article_view&sysparm_article=KB0043475) in OVHcloud using Ubuntu 22.04 LTS.
      3. You will need to [secure your server](https://help.ovhcloud.com/csm/en-gb-dedicated-servers-securing-server?id=kb_article_view&sysparm_article=KB0043969).
      4. Finally, you will need to [install Voi Swarm](../installation/installation/).
