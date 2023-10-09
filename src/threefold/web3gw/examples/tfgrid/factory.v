module tfgrid

//TODO: import tfclient
//TODO: import websocket client from vlcient.factory

//export MNEMONIC='...'
pub fn tfgridclient_example()!TFGridClient{

	if !"MNEMONIC" in os.env{
		return error("Specify 'MNEMONICS' as ENV env. do 'export MNEMONIC=...'")
	}

	mnemonic:=os.env("MNEMONIC")

	mut tfgrid_client := tfgrid.new(mut client)

	tfgrid_client.load(network:"main", mnemonic: mnemonic)!	
}