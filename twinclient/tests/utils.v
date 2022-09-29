module tests
import freeflowuniverse.crystallib.twinclient as tw
import os

const mnemonics = [
	"muscle file pear damp essence manage initial identify identify choose curtain move design stereo mom combine dish cabin neither limit dentist maximum sense absorb capital",
	"tooth lumber general mechanic census erupt raw color maze bone ball egg unfold omit poverty salt define setup asthma jeans carpet flavor awkward absent ride",
	"below library secret olympic clutch debris radio easy humble punch sock ocean axis lock consider hope can torch table old orbit address quality abandon disagree"
]

struct AlgorandDummeyData{
	// Dummey data for algorand wallets
	mut:
		user1 tw.BlockChainCreateModel
		user2 tw.BlockChainCreateModel
		user3 tw.BlockChainCreateModel
}

fn genrate_dummey_data() AlgorandDummeyData {
	mut alice 		:= tw.BlockChainCreateModel{name: "alice", mnemonic: mnemonics[0]}
	mut bob 		:= tw.BlockChainCreateModel{name: "bob", mnemonic: mnemonics[1]}
	mut baz 		:= tw.BlockChainCreateModel{name: "baz", mnemonic: mnemonics[2]}
	data := AlgorandDummeyData{
		user1: alice,
		user2: bob,
		user3: baz,
	}
	return data
}

fn init_http_client()? tw.TwinClient{
	mut transport 	:= tw.HttpTwinClient{}
	transport.init("http://localhost:3000")?
	client := tw.grid_client(transport)?
	return client
}

fn init_rmb_client()? tw.TwinClient{
	mut transport 	:= tw.RmbTwinClient{}
	transport.init([143], 5, 5)?
	client := tw.grid_client(transport)?
	return client
}

fn setup_http_algorand_tests()? (tw.TwinClient, AlgorandDummeyData) {
	env_value := os.getenv("TWIN_CLIENT_TYPE").to_lower()
	data := genrate_dummey_data()
	match env_value{
		"rmb" {client := init_rmb_client()? return client, data}
		"http" {client := init_http_client()? return client, data} 
		else {
			panic("You have to set the `TWIN_CLIENT_TYPE` variable into your environment, choices are: rmb,ws,http.")
		}
	}
}

