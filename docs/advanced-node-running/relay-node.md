# Running a Relay Node

!!! abstract
    This guide is for advanced users who want to run a relay node on the Voi network.
    If you are starting out on Voi, you should [start running a participation node](../../installation/system-requirements/) first.

Relay running is a critical part of the Voi network. It helps to relay transactions and blocks between the network participating nodes.

Running a relay is a permission-based process, and you need to [apply for permission](https://docs.voi.network/node-runners/become-a-relay-runner/)

## System Requirements

| Minimum Requirements  | Recommended Requirements |
|-----------------------|--------------------------|
| 8 CPU cores           | 12 CPU cores             |
| 16 GB RAM             | 16 GB RAM                |
| 100 GB storage        | 100 GB storage           |
| 1 Gbps network        | 1 Gbps network           |
| 30 TB egress traffic  | 40 TB egress traffic     |
| 30 TB ingress traffic | 40 TB ingress traffic    |

!!! note
    The above requirements are based on well-performing hosting providers. If you are unable to use a dedicated hosting
    provider, running a relay is not for you, as you will fail the weekly tests and be removed from the network.

## Installation

To set up a new relay node, execute the following command:

```bash
export VOINETWORK_PROFILE=relay
/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
```

## Peer limits

The default maximum number of incoming peers is 90. To change this limit, run the following command:

```bash
~/voi/bin/set-peer-limit <new_limit>
```

!!! warning
    The maximum number of incoming peers should not exceed what your node can handle.
    If you fail network performance test you may be removed from the network.
