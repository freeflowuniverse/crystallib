module keysafe

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.encoder
import encoding.binary as bin
import libsodium

pub struct PrivKey {
pub:
	name     string
	mnemonic string
	signkey  libsodium.SigningKey // master key
	privkey  libsodium.PrivateKey // derivated from master key
}

// retrieve the PubKey from the privkey
pub fn (mut key PrivKey) pubkey() []u8 {
	// TODO, this pub key is remembered per twin, this needs to be enough
	return key.privkey.public_key
}

pub fn (mut key PrivKey) decrypt(data []u8) ![]u8 {
	// TODO, this pub key is remembered per twin, this needs to be enough
	return data
}
