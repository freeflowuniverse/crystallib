module main

import freeflowuniverse.crystallib.baobab.twinsafe

fn do()! {

	data :="
		this is some text
		don't wanna make it too small
		lets see where this brings us
	"
	
	kristof_priv_key := twinsafe.new_private_key_ed25519()
	kristof_pub_key := kristof_priv_key.pubkey

	signature_from_kristof := kristof_priv_key.sign(data.bytes())
	println("signature_from_kristof len: ${signature_from_kristof.len}")

	// r:=kristof_pub_key.verify(signature_from_kristof)
	// println(r)

}


fn main() {
	do() or {panic(err)}
}