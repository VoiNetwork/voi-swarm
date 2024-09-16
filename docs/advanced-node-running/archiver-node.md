# Running an Archiver Node

!!! abstract
    This guide is for advanced users who want to run a relay node on the Voi network.
    If you are starting out on Voi, you should [start running a participation node](../../installation/system-requirements/) first.

Running archivers is a critical part of the Voi network. It provides a full history of all transactions on the chain and
can be used by indexers to provide fast access to the chain history.

Running an archive is a permission-based process, and you need to [apply for permission](https://docs.voi.network/node-runners/become-a-relay-runner/)

## System Requirements

| Minimum Requirements | Recommended Requirements |
|----------------------|--------------------------|
| 4 CPU cores          | 4 CPU cores              |
| 8 GB RAM             | 8 GB RAM                 |
| 1 TB storage         | 2 TB storage             |
| 1 Gbps network       | 1 Gbps network           |
| ? TB egress traffic  | ? TB egress traffic      |
| ? TB ingress traffic | ? TB ingress traffic     |

!!! note
The above requirements are based on well-performing hosting providers. If you are unable to use a dedicated hosting
provider, running an archive is not for you.

## Installation

To set up a new archiver node, execute the following command:

```bash
export VOINETWORK_PROFILE=archiver
export VOINETWORK_NETWORK=mainnet
/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
```

### Storage

The archive node requires a large amount of storage. The storage requirements are based on the number of transactions, and
what those transactions contain.

It is recommended that you move cold / infrequently stored data to cost-efficient storage.
On the archiver node you can do this by creating a symlink from the `/var/lib/voi/algod/data/cold-storage` folder to
the mount point of your volume.

To create a symlink link, you can run the following command:

```bash
ln -s /mnt/<cost-efficient-storage-mount-point> /var/lib/voi/algod/data/cold-storage
```

The volume used for cold storage will benefit from transparent compression being enabled.
