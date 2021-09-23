# twinclient
Client for twin_server_v2 using V Lang based on RMB

# How to use it
1. Init the Client
```V
import twinclient { init, GenericMachine }

const redis_server = 'localhost:6379'
mut twin_dest := 49 // ADD TWIN ID.
mut tw := init(redis_server, twin_dest) or { panic(err) }
```
2. Create a payload ex. generic machine
```V
payload := GenericMachine{
    node_id: 2
    public_ip: false
    cpu: u32(1)
    memory: u64(1024)
    name: 'CHOSSE NAME'
    flist: 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
    entrypoint: '/sbin/zinit init'
    disks: [Disk{
        name: 'CHOSSE DISK NAME'
        size: 10
        mountpoint: '/'
    }]
    network: Network{
        ip_range: '10.200.0.0/16'
        name: 'CHOSSE NETWORK NAME'
    }
    env: Env{
        ssh_key: 'ADD YOUR SSH KEY'
    }
}
```
3. Deploy machine using created client and payload
```V
new_machine := tw.deploy_machine(payload) or { panic(err) }
```

# Supported Commands

## Twins
- Create a new twin             --> `create_twin(<IPV6>)`
- Get info of a twin with id    --> `get_twin(<TWIN_ID>)`
- List all twins                --> `list_twins()`
- Delete twin with id           --> `delete_twin(<TWIN_ID>`

## Contracts
- Create a new contract           --> `create_contract(<NODE_ID>, <HASH>, <DATA>, <PUBLIC_IP>)`
- Get info of a contract with id  --> `get_contract(<CONTRACT_ID>)`
- Update contract                 --> `update_contract(<CONTRACT_ID>, <HASH>, <DATA>)`
- Cancel contract                 --> `cancel_contract(<CONTRACT_ID>)`

## ZOS
- Deploy workload --> `deploy(<PAYLOAD>)`

## Generic Machine
- Deploy generic machine                              --> `deploy_machine(<GenericMachine>)`
                                                      --> `deploy_machine_with_encoded_payload(<String Payload>)` In case you have the payload as string
- Get generic machine deployment info                 --> `get_machine(<MACHINE NAME>)`
- Update generic machine                              --> `update_machine(<GenericMachine>)`
                                                      --> `update_machine_with_encoded_payload(<String Payload>)` In case you have the payload as string
- List all deployed machines related to specific twin --> `list_machines()`
- Delete machine                                      --> `delete_machine(<MACHINE NAME>)`

## Kubernetes
- Deploy kubernetes                                     --> `deploy_kubernetes(<K8S>)`
                                                        --> `deploy_kubernetes_with_encoded_payload(<String Payload>)` In case you have the payload as string
- Get kubernetes deployment info                        --> `get_kubernetes(<KUBE NAME>)`
- Update kubernetes                                     --> `update_kubernetes(<K8S>)`
                                                        --> `update_kubernetes_with_encoded_payload(<String Payload>)` In case you have the payload as string
- List all deployed kubernetes related to specific twin --> `list_kubernetes()`
- Delete kubernetes                                     --> `delete_kubernetes(<KUBE NAME>)`
- Add worker                                            --> `add_worker(<DEPLOYMENT NAME>, <NODE>)`
- Delete worker                                         --> `delete worker(<DEPLOYMENT NAME>, <NODE NAME>)`

## ZDB
- Deploy zdbs                                     --> `deploy_zdbs(<DeployZDBPayload>)`
                                                        --> `deploy_zdbs_with_encoded_payload(<String Payload>)` In case you have the payload as string
- Get zdbs deployment info                        --> `get_zdbs(<ZDBS NAME>)`
- Update zdbs                                     --> `update_zdbs(<DeployZDBPayload>)`
                                                        --> `update_zdbs_with_encoded_payload(<String Payload>)` In case you have the payload as string
- List all deployed zdbs related to specific twin --> `list_zdbs()`
- Delete zdbs                                     --> `delete_zdbs(<ZDBS NAME>)`
- Add single zdb                                            --> `add_zdb(<DEPLOYMENT NAME>, <ZDB>)`
- Delete single zdb                                         --> `delete worker(<DEPLOYMENT NAME>, <ZDB NAME>)`