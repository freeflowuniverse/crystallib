## Twin Client Module

#### TwinClient is a Vlang module that can do something like communication with grid3_ts, so you just start a server in which type you chose, then you take an instance from the base interface and pass the type of TC, then you call a helper method to invoke on the grid3

#### Get more about [usage](https://github.com/freeflowuniverse/crystallib/tree/development/twinclient/examples)

#### Allowed types

- `Http`
- `Rmb`
- `Ws -> Websocket`

#### In case you want to run tests you have to export which type you will use then run the tests

#### HINT: tests support `Http` and `Rmb` types, `ws` still in progress

```sh
    export TWIN_CLIENT_TYPE=http
    # Go to https://github.com/threefoldtech/grid3_client_ts/blob/development/docs/http_server.md and follow the instructions to run the server.
    # once the server is running.
    v test twinclient/
```

### `Rmb`

dependencies:

- Redis server running
- RMB server running .e.g. [rmb_go](https://github.com/threefoldtech/rmb_go) read [docs](https://github.com/threefoldtech/rmb_go/blob/master/README.md)
- grid3 RMB server .e.g. [grid3_client_ts](https://github.com/threefoldtech/grid3_client_ts) read [docs](https://github.com/threefoldtech/grid3_client_ts/blob/development/docs/rmb_server.md)

```v
import freeflowuniverse.crystallib.twinclient as tw


fn main() {
 mut transport := tw.RmbTwinClient{}
 transport.init([143], 5, 5)?
 mut grid := tw.grid_client(transport)?
        // Now you can invoke any function below.
 grid.algorand_list()?
}
```

### `Http`

dependencies:

- grid3 Http server running see [Http server](https://github.com/threefoldtech/grid3_client_ts/blob/development/docs/http_server.md)

```v
import crystallib.twinclient as tw

fn main() {
 mut transport := tw.HttpTwinClient{}
 transport.init("http://localhost:3000")?
 mut grid := tw.grid_client(transport)?
        // Now you can invoke any function below.
        grid.algorand_list()?
}
```

### `WS`

- In this case you have to invoke grid functions inside the WebSocket server, so you have to initialize the server first and then pass the client of this server as a parameter, see [examples](https://github.com/freeflowuniverse/crystallib/tree/development/twinclient/examples)

```v
import crystallib.twinclient as tw
import net.websocket as ws
import term
import json




fn main() {
 mut s := ws.new_server(.ip6, 8081, '/')
 s.on_connect(fn (mut s ws.ServerClient) ?bool {
  if s.resource_name != '/' {
   return false
  }
  println('Client has connected...')
  return true
 })?
 s.on_message(fn (mut ws_client ws.Client, msg &tw.RawMessage) ? {
  handle_events(msg, mut ws_client)?
 })
 s.on_close(fn (mut ws ws.Client, code int, reason string) ? {
  println(term.green('client ($ws.id) closed connection'))
 })
 s.listen() or { println(term.red('error on server listen: $err')) }
 unsafe {
  s.free()
 }
}

fn handle_events(raw_msg &tw.RawMessage, mut ws_client ws.Client)? {
 if raw_msg.payload.len == 0 {
  return
 }

 mut transport := tw.WSTwinClient{}
 transport.init(mut ws_client)?
 mut grid := tw.grid_client(transport)?
 msg := json.decode(tw.Message, raw_msg.payload.bytestr()) or {
  println("cannot decode message")
  return
 }

 if msg.event == "sum_balances" {
  go fn [mut grid]()? {
   // List all algorand accounts.
   grid.algorand_list()?

   // Deploy new machine
   machines := tw.MachinesModel{
    name: 'ms1'
    network: tw.Network{
     ip_range: '10.200.0.0/16'
     name: 'net'
     add_access: false
     }
    machines: [
     tw.Machine{
      name: 'm1'
      node_id: 2
      public_ip: false
      planetary: true
      cpu: 1
      memory: 1024
      rootfs_size: 1
      flist: 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
      entrypoint: '/sbin/zinit init'
      env: tw.Env{
       ssh_key: 'ADD_YOUR_SSH'
      }
     },
    ]
   }
   twin.machines_deploy(machines)?
  }()
 } else {
  println("got a new message: $msg.event")
 }

}

```

### `Twins`

| Description                | Function                                  |
| :------------------------- | :---------------------------------------- |
| Create a new twin          | `create("IPV6")`                          |
| Get info of a twin with id | `get(<TWIN_ID>)`                          |
| Get my twin id             | `get_my_twin()`                           |
| Get twin id by account id  | `get_twin_id_by_account_id("ACCOUNT_ID")` |
| List all twins             | `list()`                                  |
| Delete twin with id        | `delete(<TWIN_ID>`                        |

### Contracts

| Description                           | Function                                                              |
| :------------------------------------ | :---------------------------------------------------------------------|
| Create a new node contract            | `create_node({NodeContractCreate})`                                   |
| Create a new name contract            | `create_name("NAME")`                                                 |
| Get info of a contract with id        | `get(<CONTRACT_ID>)`                                                  |
| Get contract id from node id and hash | `get_contract_id_by_node_id_and_hash({ContractIdByNodeIdAndHash})`    |
| Get name contract using name          | `get_name_contract("NAME")`                                           |
| Update node contract                  | `update_node_contract({NodeContractUpdate})`                          |
| List my contracts                     | `list_my_contracts()`                                                 |
| List contracts for specific twin      | `list_contracts_by_twin_id(<TWIN_ID>)`                                |
| List contracts using address          | `list_contracts_by_address("ADDRESS")`                                |
| Cancel contract                       | `cancel(<CONTRACT_ID>)`                                               |
| Cancel all my contracts               | `cancel_my_contracts()`                                               |
| Get contract consumption `TFT/hour`   | `get_consumption(<CONTRACT_ID>)`                                      |

### ZOS

| Description     | Function            |
| :-------------- | :------------------ |
| Deploy workload | `deploy("PAYLOAD")` |

### Machine

| Description                                         | Function                           |
| :-------------------------------------------------- | :--------------------------------- |
| Deploy machines -- *can have more than one machine* | `deploy({Machines})`               |
| Get machines deployment info                        | `get("MACHINES_NAME")`             |
| Update machines                                     | `update({Machines})`               |
| List all my deployed machines                       | `list()`                           |
| Add machine -- *single machine*                     | `add_machine({AddMachine})`        |
| Delete machine  -- *single machine*                 | `delete_machine({SingleDelete})`   |
| Delete machines -- *All machines in the deployment* | `delete("MACHINES_NAME")`          |

### Kubernetes

| Description                     | Function                          |
| :------------------------------ | :-------------------------------- |
| Deploy kubernetes               | `deploy({K8S})`                   |
| Get kubernetes deployment info  | `get("KUBE_NAME")`                |
| Update kubernetes               | `update({K8S})`                   |
| List all my deployed kubernetes | `list()`                          |
| Add worker                      | `add_worker({AddKubernetesNode})` |
| Delete worker                   | `delete_worker({SingleDelete})`   |
| Delete kubernetes               | `delete("KUBE_NAME")`             |

### ZDB

| Description                                  | Function                        |
| :------------------------------------------- | :------------------------------ |
| Deploy zdbs  -- *can have more than one zdb* | `deploy({ZDBs})`                |
| Get zdbs deployment info                     | `get("ZDBS_NAME")`              |
| Update zdbs                                  | `update({ZDBs})`                |
| List all my deployed zdbs                    | `list()`                        |
| Add zdb -- *single zdb*                      | `add_zdb({AddZDB})`             |
| Delete zdb -- *single zdb*                   | `delete_zdb({SingleDelete})`    |
| Delete zdbs -- *All zdbs in the deployment*  | `delete("ZDBS_NAME")`           |

### QSFS

| Description                    | Function                         |
| :----------------------------- | :--------------------------------|
| Deploy QSFS Zdbs               | `deploy({QSFSZDBs})`             |
| List all my deployed QSFS Zdbs | `list()`                         |
| Get QSFS Zdbs deployment info  | `get("QSFS_NAME")`               |
| Delete QSFS Zdbs               | `delete("QSFS_NAME")`            |

### Gateways

| Description                                          | Function                       |
| :--------------------------------------------------- | :------------------------------|
| Deploy a fully qualified domain -- *ex: site.com*    | `deploy_fqdn({GatewayFQDN})`   |
| Deploy a prefix domain -- *ex: name.gateway.grid.tf* | `deploy_name({GatewayName})`   |
| Get fqdn deployment info                             | `get_fqdn("FQDN_Name")`        |
| Get prefix domain deployment info                    | `get_name("PREFIX_NAME")`      |
| Delete deployed fqdn                                 | `delete_fqdn("FQDN_Name")`     |
| Delete deployed prefix domain                        | `delete_name("PREFIX_NAME")`   |

### KVStore

| Description                        | Function                 |
| :--------------------------------- | :------------------------|
| Set a record in KVStore            | `set("KEY", "VALUE")`    |
| Get a record in KVStore            | `get("KEY")`             |
| List all records in my KVStore     | `list()`                 |
| Remove a record from KVStore       | `remove("KEY")`          |
| Remove all records from my KVStore | `remove_all_kvstore()`   |

### Balance

| Description                                  | Function                      |
| :------------------------------------------- | :-----------------------------|
| Get current balance for specific address     | `get("ADDRESS")`              |
| Get my current balance                       | `get_my_balance()`            |
| Transfer from my account to specific address | `transfer({BalanceTransfer})` |

### Stellar

| Description                           | Function                         |
| :------------------------------------ | :------------------------------- |
| Import Wallet                         | `import_({StellarWallet})`       |
| Get Wallet by name                    | `get("NAME")`                    |
| List wallets related to specific twin | `list()`                         |
| Update wallet secret                  | `update({StellarWallet})`        |
| Get balance by name                   | `balance_by_name("NAME")`        |
| Get balance by address                | `balance_by_address("ADDRESS")`  |
| Transfer from account to another      | `transfer({StellarTransfer})`    |
| Delete a wallet from server           | `delete("NAME")`                 |
| Check if wallet exists in the server  | `exist("NAME")`                  |

### Algorand

| Description                           | Function                                      |
| :------------------------------------ | :---------------------------------------------|
| Import Wallet                         | `import_(name, mnemonics)`                    |
| Sign Bytes                            | `sign_bytes("NAME", "MSG")`                   |
| Get Wallet by name                    | `get("NAME")`                                 |
| Get all of assets by name             | `assets_by_name("NAME")`                      |
| Get all of assets by address          | `assets_by_address("ADDRESS")`                |
| Check if wallet exists in the server  | `exist("NAME")`                               |
| List wallets related to specific twin | `list()`                                      |
| Delete a wallet from server           | `delete("NAME")`                              |
| Create a new wallet                   | `create("NAME")`                              |
| Transfer from account to another      | `transfer(SENDER, RECEIVER, AMOUNT, TEXT)`    |

### TFChain

| Description                           | Function                                      |
| :------------------------------------ | :---------------------------------------------|
| Import Wallet                         | `import_(name, mnemonics)`                    |
| Get Wallet by name                    | `get("NAME")`                                 |
| Check if wallet exists in the server  | `exist("NAME")`                               |
| Update wallet secret                  | `update(NAME, MNEMONICS)`                     |
| Get all of assets by name             | `assets_by_name("NAME")`                      |
| Get all of assets by address          | `assets_by_address("ADDRESS")`                |
| List wallets related to specific twin | `list()`                                      |
| Delete a wallet from server           | `delete("NAME")`                              |
| Transfer from account to another      | `transfer(NAME, TARGET_ADDRESS, AMOUNT)`      |
