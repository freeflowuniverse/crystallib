## Cancel contracts

- canceling contracts with cancel the contact for the deployment and also delete the deployment from the node

```
import freeflowuniverse.crystallib.threefold.gridproxy
import log
import freeflowuniverse.crystallib.threefold.grid
    contracts_ids := [u64(47185), u64(47186)]
	mnemonics := grid.get_mnemonics()!
	mut deployer := grid.new_deployer(mnemonics, .dev, mut logger)!
	for cont_id in contracts_ids {
		deployer.client.cancel_contract(cont_id)!
		deployer.logger.info('contract ${cont_id} is canceled')
	}
```
