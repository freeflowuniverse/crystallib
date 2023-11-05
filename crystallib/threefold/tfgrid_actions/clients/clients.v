module clients

import freeflowuniverse.crystallib.threefold.web3gw.tfgrid { TFGridClient }
import freeflowuniverse.crystallib.threefold.web3gw.tfchain { TfChainClient }
import freeflowuniverse.crystallib.threefold.web3gw.stellar { StellarClient }
import freeflowuniverse.crystallib.threefold.web3gw.eth { EthClient }
import freeflowuniverse.crystallib.threefold.web3gw.btc { BtcClient }

pub struct Clients {
pub mut:
	tfg_client TFGridClient
	tfc_client TfChainClient
	str_client StellarClient
	eth_client EthClient
	btc_client BtcClient
}
