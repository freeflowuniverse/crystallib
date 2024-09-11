module deploy


import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model as proxy_models

@[params]
pub struct ContractGetArgs{
pub mut:
	active bool = true
}

// Retrieves all contracts (active and inactive) on the selected grid network.
//
// This function interacts with the Grid Proxy to retrieve all contracts associated
// with the twin ID of the current deployer (from GridClient).
//
// Returns:
//   - An array of `gridproxy.Contract` containing contract information.
//
// Example:
//   contracts := cn.get_my_contracts()!
pub fn (mut self TFDeployment) tfchain_contracts(args ContractGetArgs) ![]proxy_models.Contract {
	net := self.resolve_network()
	args2 := gridproxy.GridProxyClientArgs{
		net: net
		cache: true
		twin_id: cn.client.deployer.twin_id
	}

	mut proxy := gridproxy.new(args2)!
	if args.active{
		return proxy.get_contracts_active() //TODO
	}else{
		return proxy.get_contracts() //TODO
	}
	return contracts
}

// Resolves the correct grid network based on the `cn.network` value.
//
// This utility function converts the custom network type of GridContracts
// to the appropriate value in `gridproxy.TFGridNet`.
//
// Returns:
//   - A `gridproxy.TFGridNet` value corresponding to the grid network.
fn (self TFDeployment) resolve_network() gridproxy.TFGridNet {
	return match cn.network {
		.dev { gridproxy.TFGridNet.dev }
		.qa { gridproxy.TFGridNet.qa }
		.test { gridproxy.TFGridNet.test }
		.main { gridproxy.TFGridNet.main }
	}
}
