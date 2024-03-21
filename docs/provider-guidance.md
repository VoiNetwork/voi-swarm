# Provider Guidance

This guidance covers basic steps that are typical for smaller cloud / VPS providers.
It is not exhaustive, and you should consult your provider's documentation for more detailed information.

## General steps

1. Create SSH keys to authenticate with your server. With many providers, you can upload your public key
   to ensure secure password less server access.
2. Create a new server with your chosen operating system. The community frequently uses Ubuntu 22.04 LTS.
3. Secure your server by following best practices. This includes permissions, software updates and setting up firewalls.
4. [Install Voi Swarm](../installation/installation/)

Different providers have different ways to achieve these steps.

## Example

### OVHcloud

These steps are based on the OVHcloud documentation. The steps are similar to many other providers.

1. [Creating your SSH keys](https://help.ovhcloud.com/csm/en-ca-dedicated-servers-creating-ssh-keys?id=kb_article_view&sysparm_article=KB0043376)
2. [Installing your server](https://help.ovhcloud.com/csm/en-gb-dedicated-servers-getting-started-dedicated-server?id=kb_article_view&sysparm_article=KB0043475)
3. [Securing your server](https://help.ovhcloud.com/csm/en-gb-dedicated-servers-securing-server?id=kb_article_view&sysparm_article=KB0043969)
4. Lastly [install Voi Swarm](../installation/installation/)

### Contabo

1. You will need to [generate SSH keys](https://contabo.com/blog/how-to-use-ssh-keys-with-your-server/).
2. [Install a new server](https://help.contabo.com/support/solutions/articles/103000271913-how-do-i-install-my-contabo-server-) in Contabo using Ubuntu 22.04.
3. You will need to [secure your server](https://contabo.com/blog/best-practices-for-securing-remote-connections-to-your-vps/).
4. Finally, you will need to [install Voi Swarm](https://voinetwork.github.io/voi-swarm/installation/installation/)
