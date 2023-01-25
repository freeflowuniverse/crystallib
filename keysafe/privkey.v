module keysafe

import libsodium
import encoding.hex

pub struct PrivKey {
pub:
	name     string
	mnemonic string
	signkey  libsodium.SigningKey // master key
	privkey  libsodium.PrivateKey // derivated from master key
}

pub fn key_encode(key []u8) string {
	return "0x" + hex.encode(key)
}

// retrieve the master public key from PrivKey object
pub fn (key PrivKey) master_public() string {
	x := key.signkey.verify_key.public_key

	mut target := []u8{len: x.len}
	unsafe { C.memcpy(target.data, &x[0], x.len) }

	return key_encode(target)
}

// sign data with our signing key
pub fn (key PrivKey) sign(data []u8) []u8 {
	return key.signkey.sign(data)
}

