module tfgrid

import os

// TODO: import tfclient
// TODO: import websocket client from vlcient.factory

// export MNEMONIC='...'
pub fn tfgridclient_example() !TFGridClient {
	if !'MNEMONIC' in os.env {
		return error("Specify 'TFGRID_MNEMONIC' as ENV env. do 'export MNEMONIC=...'")
	}

	mnemonic := os.env('MNEMONIC')

	mut tfgrid_client := new(mut client)

	tfgrid_client.load(network: 'main', mnemonic: mnemonic)!
}
