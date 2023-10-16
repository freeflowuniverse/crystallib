# TFGrid Deployments


Create workloads in native low level format, and then use a gridriver go binary to post it to TFChain as well as send it to ZOS.


## Prerequisites

### griddriver

see https://github.com/threefoldtech/web3gw/tree/development/griddriver


### outdated

> TODO: should not be needed to use a proxy

- redis server
  - step by step installation [here](https://developer.redis.com/create/linux/)
- grid driver
  - this is a helper binary to facilitate tfgrid interactions
  - how to install:

```bash
cd 3bot/grid_driver
go build -o grid-driver
sudo mv grid-driver /usr/bin/
```

## How to deploy

- for example to make a deployment with Znet and a Zmachine, do the following:
  - create a zmachine workload.

```go
zmachine := zos.Zmachine{
    flist: 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
    network: zos.ZmachineNetwork{
        public_ip: ''
        interfaces: [
            zos.ZNetworkInterface{
                network: 'network'
                ip: '10.1.1.3'
            },
        ]
        planetary: true
    }
    compute_capacity: zos.ComputeCapacity{
        cpu: 1
        memory: i64(1024) * 1024 * 1024 * 2
    }
    env: {
        'SSH_KEY': 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCs3qtlU13/hHKLE8KUkyt+yAH7z5IKs6PH63dhkeQBBG+VdxlTg/a+6DEXqc5VVL6etKRpKKKpDVqUFKuWIK1x3sE+Q6qZ/FiPN+cAAQZjMyevkr5nmX/ofZbvGUAQGo7erxypB0Ye6PFZZVlkZUQBs31dcbNXc6CqtwunJIgWOjCMLIl/wkKUAiod7r4O2lPvD7M2bl0Y/oYCA/FnY9+3UdxlBIi146GBeAvm3+Lpik9jQPaimriBJvAeb90SYIcrHtSSe86t2/9NXcjjN8O7Fa/FboindB2wt5vG+j4APOSbvbWgpDpSfIDPeBbqreSdsqhjhyE36xWwr1IqktX+B9ZuGRoIlPWfCHPJSw/AisfFGPeVeZVW3woUdbdm6bdhoRmGDIGAqPu5Iy576iYiZJnuRb+z8yDbtsbU2eMjRCXn1jnV2GjQcwtxViqiAtbFbqX0eQ0ZU8Zsf0IcFnH1W5Tra/yp9598KmipKHBa+AtsdVu2RRNRW6S4T3MO5SU= mario@mario-machine'
    }
}

mut zmachine_workload := zos.Workload{
    version: 0
    name: 'vm2'
    type_: zos.workload_types.zmachine
    data: json.encode(zmachine)
    description: 'zmachine test'
}
```

- create a znet workload:

```go
mut network := zos.Znet{
    ip_range: '10.1.0.0/16'
    subnet: '10.1.1.0/24'
    wireguard_private_key: 'GDU+cjKrHNJS9fodzjFDzNFl5su3kJXTZ3ipPgUjOUE='
    wireguard_listen_port: 8080
    peers: [
        zos.Peer{
            subnet: '10.1.2.0/24'
            wireguard_public_key: '4KTvZS2KPWYfMr+GbiUUly0ANVg8jBC7xP9Bl79Z8zM='
            allowed_ips: ['10.1.2.0/24', '100.64.1.2/32']
        },
    ]
}

mut znet_workload := zos.Workload{
    version: 0
    name: 'network'
    type_: zos.workload_types.network
    data: json.encode_pretty(network)
    description: 'test network2'
}
```

- create a deployment containing the two workloads:

```go
mut deployment := zos.Deployment{
    version: 0
    twin_id: deployer.twin_id
    metadata: 'zm dep'
    description: 'zm kjasdf1nafvbeaf1234t21'
    workloads: [znet_workload, zmachine_workload]
    signature_requirement: zos.SignatureRequirement{
        weight_required: 1
        requests: [
            zos.SignatureRequest{
                twin_id: deployer.twin_id
                weight: 1
            },
        ]
    }
}
```

- create a deployer instance:

```vlang
    mnemonics := '<YOUR MNEMONICS>'
    substrate_url := 'wss://tfchain.dev.grid.tf/ws'
    mut client := rmb.new(nettype: rmb.TFNetType.dev, tfchain_mnemonic: mnemonics)!
    mut deployer := zos.Deployer{
        mnemonics: mnemonics
        substrate_url: substrate_url
        twin_id: 'YOUR TWIN ID'
        rmb_cl: client
    }
```

- use the deployer to deploy the deployment:

```vlang
    contract_id := deployer.deploy(node_id, mut deployment, '', 0) or {
        logger.error('failed to deploy deployment: ${err}')
        exit(1)
    }
```

For more examples, go to [examples](./examples/)
