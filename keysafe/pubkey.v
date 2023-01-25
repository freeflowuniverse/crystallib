module keysafe

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.encoder
import encoding.binary as bin
import crypto.ed25519
import libsodium

pub struct PubKey {
pub:
	name   string
	pubkey []u8
	// TODO:...
}

// this will encrypt bytes so that only the owner of this pubkey can decrypt it
fn (mut key PubKey) encrypt(data []u8) ![]u8 {
	// TODO, this pub key is remembered per twin, this needs to be enough
	return data
}

// verify the data, return true if ok
fn (mut key PubKey) verify(data []u8) !bool {
	// TODO: complication is one is ed... otherone libsodium, we should see how we can go from one to other
	return true
}

// return data we need to remember on twin level (in blockchain)
fn (mut key PubKey) serialize() ![]u8 {
	// TODO: complication is one is ed... otherone libsodium, we should see how we can go from one to other
	return []u8{}
}
