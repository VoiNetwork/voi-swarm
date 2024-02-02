# System requirements

## Supported Operating Systems and Compute Platforms

| Operating Systems | Compute Platforms |
|-------------------|-------------------|
| Debian            | arm64/amd64       |
| Ubuntu            | arm64/amd64       |

## Compute Requirements and Recommendations

| Minimum Requirements | Recommended Requirements |
|----------------------|--------------------------|
| 4 CPU cores          | 8 CPU cores              |
| 8 GB RAM             | 16 GB RAM                |
| 100 GB storage       | 200 GB storage           |
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
