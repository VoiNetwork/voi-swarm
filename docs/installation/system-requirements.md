# System requirements

## Supported Operating Systems and Compute Platforms

| Operating Systems | Compute Platforms |
|-------------------|-------------------|
| Debian            | arm64/amd64       |
| Ubuntu            | arm64/amd64       |

!!! tip
    Don't have Linux and want to run a node? [Other options are available](../../getting-started/introduction/)

## Compute Requirements and Recommendations

| Minimum Requirements | Recommended Requirements |
|----------------------|--------------------------|
| 4 CPU cores          | 8 CPU cores              |
| 8 GB RAM             | 16 GB RAM                |
| 100 GB storage       | 100 GB storage           |
| 100 Mbps network     | 1 Gbps network           |

!!! note
    The above requirements are based on the assumption that the node will be running on a dedicated machine.
    If you are running other services on the same machine, you may need to adjust the requirements accordingly.

## Why These Requirements?

The consensus algorithm used by the network is based on a protocol
that benefits from fast response times and high availability.
The requirements are set to ensure that the node can keep up with the network and provide good node health which
benefits the network as a whole, including the node runner.
If you are unable to meet these requirements, you may still be able to run a node.
However, it may not be as beneficial to the network or to you,
as your node won't be able to earn rewards effectively.

## Where Can I Run a Voi Node?

You can run a Voi node on a dedicated server, a virtual private server (VPS), or a cloud instance.

!!! tip
    If you are new to running a node,
    we recommend experimenting with a cloud instance if you are familiar with cloud providers, such as AWS, GCP, or Azure.

    If you are not familiar with these cloud providers, you can consider a Cloud or VPS provider
    such as [DigitalOcean](https://www.digitalocean.com/), [Linode](https://www.linode.com/), [OVHcloud](https://www.ovhcloud.com/), [Hetzner](https://www.hetzner.com/) or [Vultr](https://www.vultr.com/) - to name a few. We have found that onboarding is
    typically very easy and you can get started with just a few clicks.

### Considerations Before Choosing a Permanent Host

Consider node requirements, costs, location, and bandwidth before choosing a host.
Nodes on the Voi Testnet have seen up to 300 GB of incoming and 3 GB of outgoing traffic monthly.

Typically, large cloud providers charge for outgoing bandwidth usage, as well as for the resources used.
Many smaller cloud and VPS providers offer a fixed amount of bandwidth per month,
and where significant savings can be made by choosing a smaller cloud provider or a VPS provider

During Testnet we have seen costs range from $20 to $100 per month for a Voi node,
with larger cloud providers being at the higher end of the scale.

!!! note
    As a node runner, and to **avoid surprises**, it's important that you are aware of the costs
    and the terms of service of the provider you choose.

### Data Center Location

When choosing a host,
consider the location of the data center that you will be using
and whether there is [relay node capacity](https://g.testnet.voi.nodly.io/d/b315a644-1dfa-47cc-ae1e-8cf4f80a72d1/voi-master-dashboard?orgId=1&refresh=10s)
available nearby in the network.
Your node will benefit from low latency and high availability if it is located close to a relay node.
