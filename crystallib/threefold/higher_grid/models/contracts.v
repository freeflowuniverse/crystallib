module models

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model as proxy_models

pub fn (mut cn GridContractsModel) get_my_contracts() ![]proxy_models.Contract {
	net := match cn.network {
		.dev {
		 	gridproxy.TFGridNet.dev
		}
		.qa {
		 	gridproxy.TFGridNet.qa
		}
		.test {
		 	gridproxy.TFGridNet.test
		}
		.main {
		 	gridproxy.TFGridNet.main
		}
	}

	args := gridproxy.GridProxyClientArgs{
		net: net
		cache: true
	}

	mut proxy := gridproxy.new(args)!
	contracts := proxy.get_active_contracts(cn.client.deployer.twin_id)
	return contracts
}