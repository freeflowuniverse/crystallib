# twinclient
Client for Twinserver using V Lang based on RMB

# Prerequisites
1. Install Dependencies (vgrid, rmb)
2. Running RMB server
3. Running twinserver

## Install Dependencies

- vgrid:

```bash
cd $HOME/.vmodules
mkdir -p threefoldtech && cd threefoldtech #mkdir if not exist
git clone https://github.com/threefoldtech/vgrid.git
git checkout 2e708704ce2e4066b219047cd7fe2e8bf46aa7a0 # Checkout to working version
```

- rmb:

```bash
cd $HOME/.vmodules/threefoldtech
git clone https://github.com/threefoldtech/rmb.git
```

## RMB Server Steps
- Download msgbusd zip from [latest release](https://github.com/threefoldtech/rmb_go/releases) and extract it.
- There is a substrate option, choose on of:
  - devnet: `wss://tfchain.dev.grid.tf`
  - testnet: `wss://tfchain.test.grid.tf`
  - mainnet: `wss://tfchain.grid.tf` - default
- Open your terminal in the directory msgbusd downloaded, and run it.
    - `./msgbusd --mnemonics <YOUR_MNEMONICS>  # mainnet by default`

    - `./msgbusd --mnemonics <YOUR_MNEMONICS> --substrate wss://tfchain.dev.grid.tf  # Run on devnet`

- for more info, follow instruction [here](https://github.com/threefoldtech/rmb_go/blob/master/README.md)

## Twin Server Steps
- Install twin server globally:
```bash
npm install -g grid3_client
```

- Create your configuration file and fill it with your data.
```json
{
    "network": "<network environment dev or test>",
    "mnemonic": "<your account mnemonics>",
    "rmb_proxy": false, // in case http rmb proxy needs to be used
    "storeSecret": "secret", // secret used for encrypting/decrypting the values in tfkvStore
    "keypairType": "sr25519" // keypair type for the account created on substrate
}
```

- `twinserver --config <YOUR_CONFIG_FILE_PATH>`
- for more info, follow instruction [here](https://github.com/threefoldtech/grid3_client_ts/blob/development/docs/server.md)

# How to use it
```v
// 1. Init the Client
import crystallib.twinclient {init, Machines, Machine, Network, Env}
const redis_server = 'localhost:6379'
mut twin_dest := 73 // ADD TWIN ID.
mut tw := init(redis_server, twin_dest) or { panic(err) }

// 2. Create a payload ex. machines
payload := Machines{
    name: 'ms1'
    network: Network{
        ip_range: '10.200.0.0/16'
        name: 'net'
    }
    machines: [
        Machine{
            name: 'm1'
            node_id: 2
            public_ip: false
            planetary: true
            cpu: 1
            memory: 1024
            rootfs_size: 10
            flist: 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
            entrypoint: '/sbin/zinit init'
            env: Env{
                ssh_key: 'ADD_YOUR_SSH'
            }
        },
    ]
}

// 3. Deploy machine using created client and payload
new_machine := tw.deploy_machines(payload) or { panic(err) }
```
# Tests

- For each module there are many tests that can help you to use the client, **MAKE SURE TO EDIT IT WITH YOUR INFO!**.
- You have option to run single test, multiple tests or all tests using `--test or -t`
  - Single test: `v run balance_test.v --test t1_get_my_balance`
  - Multiple tests: `v run capacity_test.v -t t4_filter_nodes t5_check_farm_has_free_public_ips`
  - All tests: `v run machines_test.v` or `v run machines_test.v --test all`
  - if you enter a wrong value, list with the available tests will be printed to help you.
- If you want to add a new test cases, Kindly make sure to update the test_<MODULE> function with your case.


# Important Notes
- In the next section
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

# Supported Commands

## Twins

| Description                | Function                                  |
| :------------------------- | :---------------------------------------- |
| Create a new twin          | `create_twin("IPV6")`                     |
| Get info of a twin with id | `get_twin(<TWIN_ID>)`                     |
| Get my twin id             | `get_my_twin()`                           |
| Get twin id by account id  | `get_twin_id_by_account_id("ACCOUNT_ID")` |
| List all twins             | `list_twins()`                            |
| Delete twin with id        | `delete_twin(<TWIN_ID>`                   |

## Contracts

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

## ZOS

| Description     | Function            |
| :-------------- | :------------------ |
| Deploy workload | `deploy("PAYLOAD")` |

## Machine

| Description                                         | Function                           |
| :-------------------------------------------------- | :--------------------------------- |
| Deploy machines -- *can have more than one machine* | `deploy_machines({Machines})`      |
| Get machines deployment info                        | `get_machines("MACHINES_NAME")`    |
| Update machines                                     | `update_machines({Machines})`      |
| List all my deployed machines                       | `list_machines()`                  |
| Add machine -- *single machine*                     | `add_machine({AddMachine})`        |
| Delete machine  -- *single machine*                 | `delete_machine({SingleDelete})`   |
| Delete machines -- *All machines in the deployment* | `delete_machines("MACHINES_NAME")` |

## Kubernetes

| Description                     | Function                          |
| :------------------------------ | :-------------------------------- |
| Deploy kubernetes               | `deploy_kubernetes({K8S})`        |
| Get kubernetes deployment info  | `get_kubernetes("KUBE_NAME")`     |
| Update kubernetes               | `update_kubernetes({K8S})`        |
| List all my deployed kubernetes | `list_kubernetes()`               |
| Add worker                      | `add_worker({AddKubernetesNode})` |
| Delete worker                   | `delete_worker({SingleDelete})`   |
| Delete kubernetes               | `delete_kubernetes("KUBE_NAME")`  |

## ZDB

| Description                                  | Function                        |
| :------------------------------------------- | :------------------------------ |
| Deploy zdbs  -- *can have more than one zdb* | `deploy_zdbs({ZDBs})`           |
| Get zdbs deployment info                     | `get_zdbs("ZDBS_NAME")`         |
| Update zdbs                                  | `update_zdbs({ZDBs})`           |
| List all my deployed zdbs                    | `list_zdbs()`                   |
| Add zdb -- *single zdb*                      | `add_zdb({AddZDB})`             |
| Delete zdb -- *single zdb*                   | `delete worker({SingleDelete})` |
| Delete zdbs -- *All zdbs in the deployment*  | `delete_zdbs("ZDBS_NAME")`      |

## QSFS

| Description                    | Function                        |
| :----------------------------- | :------------------------------ |
| Deploy QSFS Zdbs               | `deploy_qsfs_zdbs({QSFSZDBs})`  |
| List all my deployed QSFS Zdbs | `list_qsfs_zdbs()`              |
| Get QSFS Zdbs deployment info  | `get_qsfs_zdbs("QSFS_NAME")`    |
| Delete QSFS Zdbs               | `delete_qsfs_zdbs("QSFS_NAME")` |

## Gateways

| Description                                          | Function                             |
| :--------------------------------------------------- | :----------------------------------- |
| Deploy a fully qualified domain -- *ex: site.com*    | `deploy_gateway_fqdn({GatewayFQDN})` |
| Deploy a prefix domain -- *ex: name.gateway.grid.tf* | `deploy_gateway_name({GatewayName})` |
| Get fqdn deployment info                             | `get_gateway_fqdn("FQDN_Name")`      |
| Get prefix domain deployment info                    | `get_gateway_name("PREFIX_NAME")`    |
| Delete deployed fqdn                                 | `delete_gateway_fqdn("FQDN_Name")`   |
| Delete deployed prefix domain                        | `delete_gateway_name("PREFIX_NAME")` |

## KVStore

| Description                        | Function                      |
| :--------------------------------- | :---------------------------- |
| Set a record in KVStore            | `set_kvstore("KEY", "VALUE")` |
| Get a record in KVStore            | `get_kvstore("KEY")`          |
| List all records in my KVStore     | `list_kvstore()`              |
| Remove a record from KVStore       | `remove_kvstore("KEY")`       |
| Remove all records from my KVStore | `remove_all_kvstore()`        |

## Balance

| Description                                  | Function                              |
| :------------------------------------------- | :------------------------------------ |
| Get current balance for specific address     | `get_balance("ADDRESS")`              |
| Get my current balance                       | `get_my_balance()`                    |
| Transfer from my account to specific address | `transfer_balance({BalanceTransfer})` |

## Stellar

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
