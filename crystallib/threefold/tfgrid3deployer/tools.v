module tfgrid3deployer

import freeflowuniverse.crystallib.threefold.gridproxy

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
