module main

import encoding.hex
import crypto.sha256
import freeflowuniverse.crystallib.keysafe.secp256k1

fn main() {
	println('[+] initializing libsecp256 vlang wrapper')

	wendy := secp256k1.new()
	wendy.generate()
	wendy.keys()

	bob := secp256k1.new()
	bob.load('0x478b45390befc3097e3e6e1a74d78a34a113f4b9ab17deb87e9b48f43893af83')
	bob.keys()

	alice := secp256k1.new()
	alice.load('0x8225825815f42e1c24a2e98714d99fee1a20b5ac864fbcb7a103cd0f37f0ffec')
	alice.keys()

	shr1 := bob.sharedkeys(alice)
	println(shr1)

	shr2 := alice.sharedkeys(bob)
	println(shr2)

	println('-----')

	message := 'Hello world, this is my awesome message'

	h256 := sha256.hexhash(message)
	println(h256)
	println(h256.len)
	println(sha256.sum(message.bytes()))

	parsed := hex.decode(h256) or { panic(err) }
	println(parsed)
	println(parsed.len)

	//
	// signature (ecdca)
	//
	signed := alice.sign_data(message.bytes())
	println(signed)

	signed_hex := alice.sign_data_hex(message.bytes())
	println(signed_hex)

	signed_str := alice.sign_str(message)
	println(signed_str)

	signed_str_hex := alice.sign_str_hex(message)
	println(signed_str_hex)

	println(alice.verify_data(signed, message.bytes()))
	println(alice.verify_str(signed_str, message))

	println('-------------------')

	//
	// signature (schnorr)
	//
	schnorr_signed := alice.schnorr_sign_data(message.bytes())
	println(schnorr_signed)

	schnorr_signed_hex := alice.schnorr_sign_data_hex(message.bytes())
	println(schnorr_signed_hex)

	schnorr_signed_str := alice.schnorr_sign_str(message)
	println(schnorr_signed_str)

	schnorr_signed_str_hex := alice.schnorr_sign_str_hex(message)
	println(schnorr_signed_str_hex)

	println(alice.schnorr_verify_data(schnorr_signed, message.bytes()))
	println(alice.schnorr_verify_str(schnorr_signed_str, message))

	// should fails, it's not the right signature
	println(alice.verify_data(schnorr_signed, message.bytes()))
	println(alice.verify_str(schnorr_signed_str, message))
}
