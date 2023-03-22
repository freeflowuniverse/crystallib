module main

import crypto.sha256
import freeflowuniverse.crystallib.keysafe.secp256k1

fn main() {
	message := 'Hello world, this is my awesome message'

	println('Coucou')
	println(sha256.hexhash(message))

	alice := secp256k1.new()
	alice.generate()
	alice.keys()

	bob := secp256k1.new()
	bob.load(alice.export())
	println(bob.export())

	// bob.load(alice.export())
	bob.keys()

	/*
	secp256k1.generate_key(alice)

	println(alice.seckey)
	println(alice.compressed)
	println(alice.xcompressed)
	*/

	// secp256k1.test()
}
