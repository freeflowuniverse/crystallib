module clients

import threefoldtech.web3gw.tfgrid { TFGridClient }
import threefoldtech.web3gw.tfchain { TfChainClient }
import threefoldtech.web3gw.stellar { StellarClient }
import threefoldtech.web3gw.eth { EthClient }
import threefoldtech.web3gw.btc { BtcClient }

pub struct Clients {
pub mut:
	tfg_client TFGridClient
	tfc_client TfChainClient
	str_client StellarClient
	eth_client EthClient
	btc_client BtcClient
}
