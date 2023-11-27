// Generate new kyes for application server and set it into environment variables.
import os
import libsodium
import encoding.base64
import term
import freeflowuniverse.crystallib.core.pathlib

fn create_keys() ! {
	sk_key := []u8{len: 32}
	pk_key := []u8{len: 32}
	_ := libsodium.crypto_sign_keypair(pk_key.data, sk_key.data)

	encoded_pk := base64.encode(pk_key)
	encoded_sk := base64.encode(sk_key)
	mut key_path := ''
	if os.args.len > 1 {
		key_path = os.args[1]
	}
	if key_path == '' {
		key_path = os.getwd()
	}
	mut p := pathlib.get_dir(path: key_path, create: true)!
	mut keyspath := p.file_get_new('keys.toml')!
	keyspath.write('[server]\nSERVER_PUBLIC_KEY="${encoded_pk}"\nSERVER_SECRET_KEY="${encoded_sk}"')!
	println('Public, Private keys generated at ${keyspath.path}')
}

fn main() {
	create_keys()!
}
