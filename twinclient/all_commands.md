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
| zdbs.deploy     |       [x]       |    [ ]     |
| zdbs.list       |       [x]       |    [ ]     |
| zdbs.get        |       [x]       |    [ ]     |
| zdbs.delete     |       [x]       |    [ ]     |
| zdbs.update     |       [x]       |    [ ]     |
| zdbs.add_zdb    |       [x]       |    [ ]     |
| zdbs.delete_zdb |       [x]       |    [ ]     |

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

| Command              | Implement State | Test State |
| :------------------- | :-------------: | :--------: |
| balance.get          |       [ ]       |    [ ]     |
| balance.transfer     |       [ ]       |    [ ]     |
| balance.getMyBalance |       [ ]       |    [ ]     |

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
