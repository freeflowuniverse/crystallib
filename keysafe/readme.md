# Keysafe

A safe implementation to help you sign, encrypt, decrypt and store your keys locally.

## Internals

When loading a keysafe object, you can specify a `directory` and a `secret`.
In that directory, a file called `.keys` will be created and encrypted using
the `secret` provided (`AES-CBC`).

Content of that file is a JSON dictionnary of key-name and it's mnemonic,
a single mnemonic is enough to derivate `ed25519` and `x25519` keys.

When loaded, private/public signing key and public/private encryption keys
are loaded and ready to be used.

- `key_generate_add()` generate a new key and store is as specified name
- `key_import_add()` import an existing key based on it's seed and specified name

## Example
```v
module main

import freeflowuniverse.crystallib.keysafe

fn main() {
	mut ks := keysafe.keysafe_get("/tmp/", "helloworld")!
	println(ks)

	ks.key_generate_add("demo") or { println(err) }
	println(ks)

	if ks.exists("demo") {
		println("key demo exists")
	}
}
```

## Keys

Note about keys: when generating a new key, the "master key" is a SigningKey Ed25519 key. From
that key, we can derivate a PrivateKey (encrypting key) X25519.

We can convert public-key only as well. On public key exchange, please always exchange the public SigningKey
(aka the master key for us). Based on that SignigKey, we can derivate the Encyption PublicKey and KeysSafe
does it for you.
