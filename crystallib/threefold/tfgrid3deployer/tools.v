module tfgrid3deployer

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.grid.models as grid_models
import rand

// Resolves the correct grid network based on the `cn.network` value.
//
// This utility function converts the custom network type of GridContracts
// to the appropriate value in `gridproxy.TFGridNet`.
//
// Returns:
//   - A `gridproxy.TFGridNet` value corresponding to the grid network.
fn resolve_network() !gridproxy.TFGridNet {
	mut cfg := get()!
	return match cfg.network {
		.dev { gridproxy.TFGridNet.dev }
		.test { gridproxy.TFGridNet.test }
		.main { gridproxy.TFGridNet.main }
		.qa { gridproxy.TFGridNet.qa }
	}
}

/*
 * This should be the node's subnet and the wireguard routing ip that should start with 100.64 then the 2nd and 3rd part of the node's subnet
*/
fn wireguard_routing_ip(ip string) string {
	parts := ip.split('.')
	return '100.64.${parts[1]}.${parts[2]}/32'
}

/*
 * Just generate a hex key for the mycelium network
*/
fn get_mycelium() grid_models.Mycelium {
	return grid_models.Mycelium{
		hex_key: rand.string(32).bytes().hex()
		peers:   []
	}
}
