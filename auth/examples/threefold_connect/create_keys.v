// Generate new kyes for application server and set it into environment variables.

import os
import libsodium
import encoding.base64

pub fn create_keys()? {
	sk_key := []u8{len: 32}
	pk_key := []u8{len: 32}
	_ := libsodium.crypto_sign_keypair(pk_key.data, sk_key.data)

	encoded_pk:= base64.encode(pk_key)
	encoded_sk := base64.encode(sk_key)	
	file_path := './keys.toml'

	os.create(file_path) or {
		panic("Could not create file")
	}
	os.write_file(file_path, '[server]\nSERVER_PUBLIC_KEY="$encoded_pk"\nSERVER_SECRET_KEY="$encoded_sk"')?
	println("Public, Private keys generated at $file_path")
}

fn main() {
	create_keys()?
}