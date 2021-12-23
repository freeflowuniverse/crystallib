# All Commands
Here are all commands supported by twinserver
> checked already implemented

## Machines
[x]machines.deploy
[x]machines.list
[x]machines.get
[x]machines.delete
[x]machines.update
[]machines.add_machine
[]machines.delete_machine

## Kubernetes
[x]k8s.deploy
[x]k8s.list
[x]k8s.get
[x]k8s.delete
[x]k8s.update
[x]k8s.add_worker
[x]k8s.delete_worker

## ZDBs
[x]zdbs.deploy
[x]zdbs.list
[x]zdbs.get
[x]zdbs.delete
[x]zdbs.update
[x]zdbs.add_zdb
[x]zdbs.delete_zdb

## Gateways
[]gateway.deploy_fqdn
[]gateway.deploy_name
[]gateway.get_fqdn
[]gateway.delete_fqdn
[]gateway.get_name
[]gateway.delete_name

## QSFS
[]qsfs_zdbs.deploy
[]qsfs_zdbs.list
[]qsfs_zdbs.get
[]qsfs_zdbs.delete

## ZOS
[x]zos.deploy

## Contracts
[x]contracts.create_node
[]contracts.create_name
[x]contracts.get
[]contracts.get_contract_id_by_node_id_and_hash
[]contracts.get_node_contracts
[]contracts.get_name_contract
[x]contracts.update_node
[x]contracts.cancel
[]contracts.listMyContracts
[]contracts.listContractsByTwinId
[]contracts.listContractsByAddress
[]contracts.cancelMyContracts
[]contracts.getConsumption

# Twins
[x]twins.create
[x]twins.get
[]twins.get_my_twin_id
[]twins.get_twin_id_by_account_id
[x]twins.list
[x]twins.delete

## kvstore
[]kvstore.set
[]kvstore.get
[]kvstore.list
[]kvstore.remove
[]kvstore.removeAll

## Balance
[]balance.get
[]balance.transfer
[]balance.getMyBalance

## Capacity
[]capacity.getFarms
[]capacity.getNodes
[]capacity.getAllFarms
[]capacity.getAllNodes
[]capacity.filterNodes
[]capacity.checkFarmHasFreePublicIps
[]capacity.getNodesByFarmId
[]capacity.getNodeFreeResources
[]capacity.getFarmIdFromFarmName

## Stellar
[x]stellar.import
[x]stellar.get
[x]stellar.update
[x]stellar.exist
[x]stellar.list
[x]stellar.balance_by_name
[x]stellar.balance_by_address
[x]stellar.transfer
[x]stellar.delete