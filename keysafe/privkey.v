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
	return '0x' + hex.encode(key)
}

// retrieve the master public key from PrivKey object
// this is the public key as need to be shared to a remote user to verify that we signed with our private key
// is shared as hex key in string format (66 chars)
pub fn (key PrivKey) master_public() string {
	x := key.signkey.verify_key.public_key

	mut target := []u8{len: x.len}
	unsafe { C.memcpy(target.data, &x[0], x.len) }

	return key_encode(target)
}

// sign data with our signing key
// data is bytestr
// output is []u8 bytestring
// to get bytes from string do: mystring.bytes().
pub fn (key PrivKey) sign(data []u8) []u8 {
	return key.signkey.sign(data)
}

// sign data with our signing key.
// data is bytestr.
// output is hex string.
// to get bytes from string do: mystring.bytes().
// size of output is ?
pub fn (key PrivKey) sign_hex(data []u8) string {
	return hex.encode(key.sign(data))
}
