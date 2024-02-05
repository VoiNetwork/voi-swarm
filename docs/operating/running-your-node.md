# Keeping Your Node Healthy

!!! info inline end "A healthy node is a happy node"
    We are working on improving the running experience by automating and simplifying as much as possible. Join the [Discord](https://discord.com/invite/vnFbrJrHeW) and provide your feedback!

To operate your node and manage your accounts, you can use the Voi CLI tools.
The Voi CLI tools is a bundle of commands
that allow you to manage common operation related to the network, as well as your setup.
The Voi CLI tools are installed with the Voi Swarm package.

As a participant, it's important that you continuously monitor the health of your node, this includes monitoring system
metrics, node health as well as ensuring participation keys are up-to-date.

| Metrics                  | Description                                   | How to Monitor                                                                                                                                                                       | Feature in Voi Swarm |
|--------------------------|-----------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------|
| Compute platform metrics | CPU load, disk usage, network bandwidth, etc. | Use cloud / system monitoring tools, [Voi Checker](https://github.com/crypto-morph/voi-checker)                                                                                      | :material-minus:     |
| Node health              | Node status, participation status, etc.       | Use [Voi Checker](https://github.com/crypto-morph/voi-checker), [Voi Proposer Data](https://cswenor.github.io/voi-proposer-data/health.html), [Voi Nodes v2](https://voi-nodes.dev/) | :material-minus:     |
| Participation keys       | Participation key status and expiration       | Use [CLI tools](../cli-tools.md) to check participation status and setup. Voi Swarm offers [notifications on key expiration](../setup-notifications)                                 | :material-plus:      |

Contributions to improve the health monitoring of the Voi node are welcome.
Please join the [Voi Network Discord server](https://discord.com/invite/vnFbrJrHeW) to discuss with other community members and contributors. You can also open an issue or a pull request on GitHub.
