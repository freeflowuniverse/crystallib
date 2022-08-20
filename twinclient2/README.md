# TwinClient2 (GridClient over ws)

## Overview:
this demonstrate how we can use custom JSON_RPC functionality over ws protocol to allow p2p communications (both ends can send requests and receive responses) between Vlang ws server and grid3_client js library (running in user browser).

- we start a server that hosts a SPA (single page application) that do two things:
    - loads grid3_client js library (https://github.com/threefoldtech/grid3_client_ts) to enable functionality to interact with threefold gird.
    - start a websocket connection to the Vlang server.
- when the user access this SPA, and provide the mnemonics, etc, the SPA will initialize the grid3_client.
- now both the SPA and our backend can communicate with each other using JSON_RPC over the established ws connection.

## What is TwinClient2:

tw2 is a Vlang library to be imported and used from a ws server to enable developers access the functionality of grid3_client js library with ease. you can think of it as a V wrapper around grid3_client js library.

## how to use TwinClient2:

- it is expected that you will have a ws server which from you can import `tw2` within it.
- it is expected that you will interact with a js ws client that will (at least) forward the requests the the grid3_client `invoke` method.

for these requirmenets, you can use the server and client(SPA) in this repo as a starter.
https://github.com/freeflowuniverse/twinactions/tree/development_tfgrid_websocket_server_wip_gridclient

Note: the models was ported from `crystallib/twinclient` and need to be tested and verified that they are updated. only subset of the models was tested.

```v
// importing tw2
import twinclient2 as tw2
// initialize the client with the ws client:
mut tw2_client := tw2.init_client(mut ws_client) // repeated calls to init_client will return the same twin client if the ws_client is the same.
```

### call a high-level method:
```v
id := tw2_client.get_my_twin_id() or { // handle the error }
```

### call a low level `send` method:
```v
// execute arbitrary JSON_RPC request if supported by the grid3 client
id := tw2_client.send('twin.get_my_twin_id', '{}') or { // handle the error }
```

## examples:
```v 
import freeflowuniverse.crystallib.twinclient2 as tw2
mut tw2_client := tw2.init_client(mut ws_client)
go fn [mut tw2_client]() {
    payload := Machines{
        name: 'ms1'
        network: Network{
            ip_range: '10.200.0.0/16'
            name: 'net'
            add_access: false
            }
        machines: [
            Machine{
                name: 'm1'
                node_id: 2
                public_ip: false
                planetary: true
                cpu: 1
                memory: 1024
                rootfs_size: 1
                flist: 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
                entrypoint: '/sbin/zinit init'
                env: Env{
                    ssh_key: 'ADD_YOUR_SSH'
                }
            },
        ]
    }
    response := client.deploy_machines(machines)?
}()
```
wrapping the sync code that interact with the grid3_client in a separated thread is a must, otherwise the ws client will be blocked.

```v
go fn [mut client]() {
    // do something with the twin client
    // or the underneath ws client methods
}()
```

## Supported Commands

- In this section
  - Anything between `{}`  will be a struct in [models.v](./models.v) file.
  - Anything between `""`  will be a string.
  - Anything between `<>` will be a number.
- if any struct tagged with `[params]` you can pass it to function as parameters.

```v
[params]
struct Person{
    id   int
    name string
}

pub fn setPerson(p Person){
    /// Anything
}

setPerson(id:1, name:"Essam")
```

### Twins

| Description                | Function                                  |
| :------------------------- | :---------------------------------------- |
| Create a new twin          | `create_twin("IPV6")`                     |
| Get info of a twin with id | `get_twin(<TWIN_ID>)`                     |
| Get my twin id             | `get_my_twin()`                           |
| Get twin id by account id  | `get_twin_id_by_account_id("ACCOUNT_ID")` |
| List all twins             | `list_twins()`                            |
| Delete twin with id        | `delete_twin(<TWIN_ID>`                   |

### Contracts

| Description                           | Function                                                        |
| :------------------------------------ | :-------------------------------------------------------------- |
| Create a new node contract            | `create_node_contract({NodeContractCreate})`                    |
| Create a new name contract            | `create_name_contract("NAME")`                                  |
| Get info of a contract with id        | `get_contract(<CONTRACT_ID>)`                                   |
| Get contract id from node id and hash | `get_contract_id_by_node_and_hash({ContractIdByNodeIdAndHash})` |
| Get name contract using name          | `get_name_contract("NAME")`                                     |
| Update node contract                  | `update_node_contract({NodeContractUpdate})`                    |
| List my contracts                     | `list_my_contracts()`                                           |
| List contracts for specific twin      | `list_contracts_by_twin_id(<TWIN_ID>)`                          |
| List contracts using address          | `list_contracts_by_address("ADDRESS")`                          |
| Cancel contract                       | `cancel_contract(<CONTRACT_ID>)`                                |
| Cancel all my contracts               | `cancel_my_contracts()`                                         |
| Get contract consumption `TFT/hour`   | `get_consumption(<CONTRACT_ID>)`                                |

### ZOS

| Description     | Function            |
| :-------------- | :------------------ |
| Deploy workload | `deploy("PAYLOAD")` |

### Machine

| Description                                         | Function                           |
| :-------------------------------------------------- | :--------------------------------- |
| Deploy machines -- *can have more than one machine* | `deploy_machines({Machines})`      |
| Get machines deployment info                        | `get_machines("MACHINES_NAME")`    |
| Update machines                                     | `update_machines({Machines})`      |
| List all my deployed machines                       | `list_machines()`                  |
| Add machine -- *single machine*                     | `add_machine({AddMachine})`        |
| Delete machine  -- *single machine*                 | `delete_machine({SingleDelete})`   |
| Delete machines -- *All machines in the deployment* | `delete_machines("MACHINES_NAME")` |

### Kubernetes

| Description                     | Function                          |
| :------------------------------ | :-------------------------------- |
| Deploy kubernetes               | `deploy_kubernetes({K8S})`        |
| Get kubernetes deployment info  | `get_kubernetes("KUBE_NAME")`     |
| Update kubernetes               | `update_kubernetes({K8S})`        |
| List all my deployed kubernetes | `list_kubernetes()`               |
| Add worker                      | `add_worker({AddKubernetesNode})` |
| Delete worker                   | `delete_worker({SingleDelete})`   |
| Delete kubernetes               | `delete_kubernetes("KUBE_NAME")`  |

### ZDB

| Description                                  | Function                        |
| :------------------------------------------- | :------------------------------ |
| Deploy zdbs  -- *can have more than one zdb* | `deploy_zdbs({ZDBs})`           |
| Get zdbs deployment info                     | `get_zdbs("ZDBS_NAME")`         |
| Update zdbs                                  | `update_zdbs({ZDBs})`           |
| List all my deployed zdbs                    | `list_zdbs()`                   |
| Add zdb -- *single zdb*                      | `add_zdb({AddZDB})`             |
| Delete zdb -- *single zdb*                   | `delete worker({SingleDelete})` |
| Delete zdbs -- *All zdbs in the deployment*  | `delete_zdbs("ZDBS_NAME")`      |

### QSFS

| Description                    | Function                        |
| :----------------------------- | :------------------------------ |
| Deploy QSFS Zdbs               | `deploy_qsfs_zdbs({QSFSZDBs})`  |
| List all my deployed QSFS Zdbs | `list_qsfs_zdbs()`              |
| Get QSFS Zdbs deployment info  | `get_qsfs_zdbs("QSFS_NAME")`    |
| Delete QSFS Zdbs               | `delete_qsfs_zdbs("QSFS_NAME")` |

### Gateways

| Description                                          | Function                             |
| :--------------------------------------------------- | :----------------------------------- |
| Deploy a fully qualified domain -- *ex: site.com*    | `deploy_gateway_fqdn({GatewayFQDN})` |
| Deploy a prefix domain -- *ex: name.gateway.grid.tf* | `deploy_gateway_name({GatewayName})` |
| Get fqdn deployment info                             | `get_gateway_fqdn("FQDN_Name")`      |
| Get prefix domain deployment info                    | `get_gateway_name("PREFIX_NAME")`    |
| Delete deployed fqdn                                 | `delete_gateway_fqdn("FQDN_Name")`   |
| Delete deployed prefix domain                        | `delete_gateway_name("PREFIX_NAME")` |

### KVStore

| Description                        | Function                      |
| :--------------------------------- | :---------------------------- |
| Set a record in KVStore            | `set_kvstore("KEY", "VALUE")` |
| Get a record in KVStore            | `get_kvstore("KEY")`          |
| List all records in my KVStore     | `list_kvstore()`              |
| Remove a record from KVStore       | `remove_kvstore("KEY")`       |
| Remove all records from my KVStore | `remove_all_kvstore()`        |

### Balance

| Description                                  | Function                              |
| :------------------------------------------- | :------------------------------------ |
| Get current balance for specific address     | `get_balance("ADDRESS")`              |
| Get my current balance                       | `get_my_balance()`                    |
| Transfer from my account to specific address | `transfer_balance({BalanceTransfer})` |

### Stellar

| Description                           | Function                         |
| :------------------------------------ | :------------------------------- |
| Import Wallet                         | `import_wallet({StellarWallet})` |
| Get Wallet by name                    | `get_wallet("NAME")`             |
| List wallets related to specific twin | `list_wallets()`                 |
| Update wallet secret                  | `update_wallet({StellarWallet})` |
| Get balance by name                   | `balance_by_name("NAME")`        |
| Get balance by address                | `balance_by_address("ADDRESS")`  |
| Transfer from account to another      | `transfer({StellarTransfer})`    |
| Delete a wallet from server           | `delete_wallet("NAME")`          |
| Check if wallet exists in the server  | `is_wallet_exist("NAME")`        |
