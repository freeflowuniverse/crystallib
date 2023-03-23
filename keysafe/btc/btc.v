module main

import encoding.hex
import crypto.sha256
import freeflowuniverse.crystallib.keysafe.secp256k1

fn main() {
	println("[+] initializing libsecp256 vlang wrapper")

	wendy := secp256k1.new()
	wendy.generate()
	wendy.keys()

	bob := secp256k1.new()
	bob.load("0x478b45390befc3097e3e6e1a74d78a34a113f4b9ab17deb87e9b48f43893af83")
	bob.keys()

	alice := secp256k1.new()
	alice.load("0x8225825815f42e1c24a2e98714d99fee1a20b5ac864fbcb7a103cd0f37f0ffec")
	alice.keys()

	shr1 := bob.sharedkeys(alice)
	println(shr1)

	shr2 := alice.sharedkeys(bob)
	println(shr2)
	

	message := 'Hello world, this is my awesome message'
	h256 := sha256.hexhash(message)
	println(h256)
	parsed := hex.decode(h256) or { panic(err) }
	println(parsed)

	
}
