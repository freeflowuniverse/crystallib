module models

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model as proxy_models

// Retrieves the active contracts for the current twin on the selected grid network.
//
// This function interacts with the Grid Proxy to retrieve all `state=created` contracts
// associated with the twin ID of the current deployer (from GridClient).
//
// Returns:
//   - An array of `gridproxy.Contract` containing active contract information.
//
// Example:
//   contracts := cn.get_my_active_contracts()!
pub fn (mut cn GridContractsModel) get_my_active_contracts() ![]proxy_models.Contract {
	net := cn.resolve_network() // Refactored to use a common function for network resolution
	args := gridproxy.GridProxyClientArgs{
		net: net
		cache: true
	}
	mut proxy := gridproxy.new(args)!
	contracts := proxy.get_active_contracts(cn.client.deployer.twin_id)
	return contracts
}

// Retrieves all contracts (active and inactive) for the current twin on the selected grid network.
//
// This function interacts with the Grid Proxy to retrieve all contracts associated
// with the twin ID of the current deployer (from GridClient).
//
// Returns:
//   - An array of `gridproxy.Contract` containing all contract information.
//
// Example:
//   contracts := cn.get_my_contracts()!
pub fn (mut cn GridContractsModel) get_my_contracts() ![]proxy_models.Contract {
	net := cn.resolve_network()
	args := gridproxy.GridProxyClientArgs{
		net: net
		cache: true
	}
	mut proxy := gridproxy.new(args)!
	contracts := proxy.get_contracts_by_twin_id(cn.client.deployer.twin_id)
	return contracts
}

// Resolves the correct grid network based on the `cn.network` value.
//
// This utility function converts the custom network type of GridContractsModel
// to the appropriate value in `gridproxy.TFGridNet`.
//
// Returns:
//   - A `gridproxy.TFGridNet` value corresponding to the grid network.
fn (cn GridContractsModel) resolve_network() gridproxy.TFGridNet {
	return match cn.network {
		.dev { gridproxy.TFGridNet.dev }
		.qa { gridproxy.TFGridNet.qa }
		.test { gridproxy.TFGridNet.test }
		.main { gridproxy.TFGridNet.main }
	}
}
