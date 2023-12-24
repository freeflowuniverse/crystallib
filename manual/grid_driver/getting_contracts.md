## Getting contracts

- to get contracts of your deployments

```
import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model
import freeflowuniverse.crystallib.threefold.grid

	mut grid_proxy := gridproxy.get(.dev, false)!
	contracts := grid_proxy.get_contracts(
		twin_id: model.OptionU64(u64(deployer.twin_id))
		state: 'created'
	)!
```
