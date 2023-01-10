module keysafe
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.encoder
import encoding.binary as bin
import crypto.ed25519
import libsodium


pub struct PrivKey{
pub:
	name string
	privkey libsodium.PrivateKey
	signkey	ed25519.PrivateKey
}



//TODO: can we go from private key of libsodiun to ed25519 or other way around?

//retrieve the PubKey from the privkey
pub fn (mut key PrivKey) pubkey() ! PubKey{
	//TODO, this pub key is remembered per twin, this needs to be enough
	return PubKey{}
}

pub fn (mut key PrivKey) decrypt(data []u8) ! []u8{
	//TODO, this pub key is remembered per twin, this needs to be enough
	return data
}

