# All Commands
Here are all commands supported by twinserver and its status in twinclient

## Machines

| Command                 | Implement State | Test State |
| :---------------------- | :-------------: | :--------: |
| machines.deploy         |       [x]       |    [x]     |
| machines.list           |       [x]       |    [x]     |
| machines.get            |       [x]       |    [x]     |
| machines.delete         |       [x]       |    [x]     |
| machines.update         |       [x]       |    [ ]     |
| machines.add_machine    |       [x]       |    [x]     |
| machines.delete_machine |       [x]       |    [x]     |

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

| Command         | Implement State | Test State |
| :-------------- | :-------------: | :--------: |
| zdbs.deploy     |       [x]       |    [x]     |
| zdbs.list       |       [x]       |    [x]     |
| zdbs.get        |       [x]       |    [x]     |
| zdbs.delete     |       [x]       |    [x]     |
| zdbs.update     |       [x]       |    [ ]     |
| zdbs.add_zdb    |       [x]       |    [x]     |
| zdbs.delete_zdb |       [x]       |    [x]     |

## Gateways

| Command             | Implement State | Test State |
| :------------------ | :-------------: | :--------: |
| gateway.deploy_fqdn |       [x]       |    [ ]     |
| gateway.deploy_name |       [x]       |    [ ]     |
| gateway.get_fqdn    |       [x]       |    [ ]     |
| gateway.delete_fqdn |       [x]       |    [ ]     |
| gateway.get_name    |       [x]       |    [ ]     |
| gateway.delete_name |       [x]       |    [ ]     |

## QSFS

| Command          | Implement State | Test State |
| :--------------- | :-------------: | :--------: |
| qsfs_zdbs.deploy |       [x]       |    [x]     |
| qsfs_zdbs.list   |       [x]       |    [x]     |
| qsfs_zdbs.get    |       [x]       |    [x]     |
| qsfs_zdbs.delete |       [x]       |    [x]     |

## ZOS

| Command    | Implement State | Test State |
| :--------- | :-------------: | :--------: |
| zos.deploy |       [x]       |    [ ]     |

## Contracts

| Command                                       | Implement State | Test State |
| :-------------------------------------------- | :-------------: | :--------: |
| contracts.create_node                         |       [x]       |    [x]     |
| contracts.create_name                         |       [x]       |    [x]     |
| contracts.get                                 |       [x]       |    [x]     |
| contracts.get_contract_id_by_node_id_and_hash |       [x]       |    [x]     |
| contracts.get_name_contract                   |       [x]       |    [x]     |
| contracts.update_node                         |       [x]       |    [x]     |
| contracts.cancel                              |       [x]       |    [x]     |
| contracts.listMyContracts                     |       [x]       |    [x]     |
| contracts.listContractsByTwinId               |       [x]       |    [x]     |
| contracts.listContractsByAddress              |       [x]       |    [x]     |
| contracts.cancelMyContracts                   |       [x]       |    [x]     |
| contracts.getConsumption                      |       [x]       |    [x]     |

# Twins

| Command                         | Implement State | Test State | Notes                        |
| :------------------------------ | :-------------: | :--------: | :--------------------------- |
| twins.create                    |       [x]       |    [ ]     | Need a new ip to test with   |
| twins.get                       |       [x]       |    [x]     |                              |
| twins.get_my_twin_id            |       [x]       |    [x]     |                              |
| twins.get_twin_id_by_account_id |       [x]       |    [x]     |                              |
| twins.list                      |       [x]       |    [x]     |                              |
| twins.delete                    |       [x]       |    [ ]     | Need my twin can't delete it |

## kvstore

| Command           | Implement State | Test State |
| :---------------- | :-------------: | :--------: |
| kvstore.set       |       [x]       |    [x]     |
| kvstore.get       |       [x]       |    [x]     |
| kvstore.list      |       [x]       |    [x]     |
| kvstore.remove    |       [x]       |    [x]     |
| kvstore.removeAll |       [x]       |    [x]     |

## Balance

| Command              | Implement State | Test State | Notes                                                                                    |
| :------------------- | :-------------: | :--------: | :--------------------------------------------------------------------------------------- |
| balance.get          |       [x]       |    [x]     |                                                                                          |
| balance.transfer     |       [x]       |    [ ]     | Issue [grid3_client_ts/174](https://github.com/threefoldtech/grid3_client_ts/issues/174) |
| balance.getMyBalance |       [x]       |    [x]     |                                                                                          |

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
