module main

import freeflowuniverse.crystallib.threefold.griddriver { Client }

fn main () {
	mut client := Client{
		mnemonic: "mom picnic deliver again rug night rabbit music motion hole lion where",
		substrate: "wss://tfchain.dev.grid.tf/ws",
		relay: "wss://relay.dev.grid.tf/ws",
	}

	res := client.get_zos_version()!

	println(res)
}