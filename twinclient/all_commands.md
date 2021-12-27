# All Commands
Here are all commands supported by twinserver and its status in twinclient

## Machines

| Command                 | Implement State | Test State | Notes                   |
| :---------------------- | :-------------: | :--------: | :---------------------- |
| machines.deploy         |       [x]       |    [x]     |                         |
| machines.list           |       [x]       |    [x]     |                         |
| machines.get            |       [x]       |    [x]     |                         |
| machines.delete         |       [x]       |    [x]     |                         |
| machines.update         |       [x]       |    [ ]     | Need to verify it again |
| machines.add_machine    |       [x]       |    [x]     |                         |
| machines.delete_machine |       [x]       |    [x]     |                         |

## Kubernetes

| Command           | Implement State | Test State |
| :---------------- | :-------------: | :--------: |
| k8s.deploy        |       [x]       |    [x]     |
| k8s.list          |       [x]       |    [x]     |
| k8s.get           |       [x]       |    [x]     |
| k8s.delete        |       [x]       |    [x]     |
| k8s.update        |       [x]       |    [ ]     |
| k8s.add_worker    |       [x]       |    [x]     |
| k8s.delete_worker |       [x]       |    [x]     |

## ZDBs

| Command         | Implement State | Test State | Notes                                                                                |
| :-------------- | :-------------: | :--------: | :----------------------------------------------------------------------------------- |
| zdbs.deploy     |       [x]       |    [ ]     | Can't test according to [zos/1517](https://github.com/threefoldtech/zos/issues/1517) |
| zdbs.list       |       [x]       |    [ ]     | Same                                                                                 |
| zdbs.get        |       [x]       |    [ ]     | Same                                                                                 |
| zdbs.delete     |       [x]       |    [ ]     | Same                                                                                 |
| zdbs.update     |       [x]       |    [ ]     | Same                                                                                 |
| zdbs.add_zdb    |       [x]       |    [ ]     | Same                                                                                 |
| zdbs.delete_zdb |       [x]       |    [ ]     | Same                                                                                 |

## Gateways

| Command             | Implement State | Test State |
| :------------------ | :-------------: | :--------: |
| gateway.deploy_fqdn |       [ ]       |    [ ]     |
| gateway.deploy_name |       [ ]       |    [ ]     |
| gateway.get_fqdn    |       [ ]       |    [ ]     |
| gateway.delete_fqdn |       [ ]       |    [ ]     |
| gateway.get_name    |       [ ]       |    [ ]     |
| gateway.delete_name |       [ ]       |    [ ]     |

## QSFS

| Command          | Implement State | Test State |
| :--------------- | :-------------: | :--------: |
| qsfs_zdbs.deploy |       [ ]       |    [ ]     |
| qsfs_zdbs.list   |       [ ]       |    [ ]     |
| qsfs_zdbs.get    |       [ ]       |    [ ]     |
| qsfs_zdbs.delete |       [ ]       |    [ ]     |

## ZOS

| Command    | Implement State | Test State |
| :--------- | :-------------: | :--------: |
| zos.deploy |       [x]       |    [ ]     |

## Contracts

| Command                                       | Implement State | Test State |
| :-------------------------------------------- | :-------------: | :--------: |
| contracts.create_node                         |       [x]       |    [ ]     |
| contracts.create_name                         |       [ ]       |    [ ]     |
| contracts.get                                 |       [x]       |    [ ]     |
| contracts.get_contract_id_by_node_id_and_hash |       [ ]       |    [ ]     |
| contracts.get_node_contracts                  |       [ ]       |    [ ]     |
| contracts.get_name_contract                   |       [ ]       |    [ ]     |
| contracts.update_node                         |       [x]       |    [ ]     |
| contracts.cancel                              |       [x]       |    [ ]     |
| contracts.listMyContracts                     |       [ ]       |    [ ]     |
| contracts.listContractsByTwinId               |       [ ]       |    [ ]     |
| contracts.listContractsByAddress              |       [ ]       |    [ ]     |
| contracts.cancelMyContracts                   |       [ ]       |    [ ]     |
| contracts.getConsumption                      |       [ ]       |    [ ]     |

# Twins

| Command                         | Implement State | Test State |
| :------------------------------ | :-------------: | :--------: |
| twins.create                    |       [x]       |    [ ]     |
| twins.get                       |       [x]       |    [x]     |
| twins.get_my_twin_id            |       [ ]       |    [ ]     |
| twins.get_twin_id_by_account_id |       [ ]       |    [ ]     |
| twins.list                      |       [x]       |    [ ]     |
| twins.delete                    |       [x]       |    [ ]     |

## kvstore

| Command           | Implement State | Test State |
| :---------------- | :-------------: | :--------: |
| kvstore.set       |       [ ]       |    [ ]     |
| kvstore.get       |       [ ]       |    [ ]     |
| kvstore.list      |       [ ]       |    [ ]     |
| kvstore.remove    |       [ ]       |    [ ]     |
| kvstore.removeAll |       [ ]       |    [ ]     |

## Balance

| Command              | Implement State | Test State | Notes                                                                                                                                                                                          |
| :------------------- | :-------------: | :--------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| balance.get          |       [x]       |    [x]     |                                                                                                                                                                                                |
| balance.transfer     |       [x]       |    [ ]     | Transfer done but return error `[ERR_INVALID_ARG_TYPE]: The first argument must be of type string or an instance of Buffer, ArrayBuffer, or Array or an Array-like Object. Received undefined` |
| balance.getMyBalance |       [x]       |    [x]     |                                                                                                                                                                                                |

## Capacity

| Command                            | Implement State | Test State |
| :--------------------------------- | :-------------: | :--------: |
| capacity.getFarms                  |       [ ]       |    [ ]     |
| capacity.getNodes                  |       [ ]       |    [ ]     |
| capacity.getAllFarms               |       [ ]       |    [ ]     |
| capacity.getAllNodes               |       [ ]       |    [ ]     |
| capacity.filterNodes               |       [ ]       |    [ ]     |
| capacity.checkFarmHasFreePublicIps |       [ ]       |    [ ]     |
| capacity.getNodesByFarmId          |       [ ]       |    [ ]     |
| capacity.getNodeFreeResources      |       [ ]       |    [ ]     |
| capacity.getFarmIdFromFarmName     |       [ ]       |    [ ]     |

## Stellar

| Command                    | Implement State | Test State |
| :------------------------- | :-------------: | :--------: |
| stellar.import             |       [x]       |    [ ]     |
| stellar.get                |       [x]       |    [ ]     |
| stellar.update             |       [x]       |    [ ]     |
| stellar.exist              |       [x]       |    [ ]     |
| stellar.list               |       [x]       |    [ ]     |
| stellar.balance_by_name    |       [x]       |    [ ]     |
| stellar.balance_by_address |       [x]       |    [ ]     |
| stellar.transfer           |       [x]       |    [ ]     |
| stellar.delete             |       [x]       |    [ ]     |
