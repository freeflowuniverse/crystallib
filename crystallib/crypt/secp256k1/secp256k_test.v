module secp256k1

import encoding.hex
import crypto.sha256
import freeflowuniverse.crystallib.crypt.secp256k1

fn test_check() {
	println('${'[+] initializing libsecp256 vlang wrapper'}')

	wendy := secp256k1.new()!
	webdy_priv_key := wendy.private_key_hex()
	webdy_pub_key := wendy.public_key_hex()
	println('-------')
	println('Wendy Private: ${webdy_priv_key}')
	println('Wendy Public: ${webdy_pub_key}')
	println('-------')

	// create 'bob' from a private key, full features will be available
	bob := secp256k1.new(
		privhex: '0x478b45390befc3097e3e6e1a74d78a34a113f4b9ab17deb87e9b48f43893af83'
	)!

	// create 'alice' from a private key, full features will be available
	alice := secp256k1.new(
		privhex: '0x8225825815f42e1c24a2e98714d99fee1a20b5ac864fbcb7a103cd0f37f0ffec'
	)!

	// create 'bobpub' from bob only public key, reduced features available (only sign check, shared keys, etc.)
	bobpub := secp256k1.new(
		pubhex: bob.public_key_hex()
	)!

	// create 'alicepub' from alice only public key, reduced features available
	alicepub := secp256k1.new(
		pubhex: alice.public_key_hex()
	)!

	shr1 := bob.sharedkeys(alice)
	println('${shr1}')

	shr2 := alice.sharedkeys(bob)
	println('${shr2}')

	// example in real world, where private key is available and only target public key
	shr1pub := bob.sharedkeys(alicepub)
	println('${shr1pub}')

	shr2pub := alice.sharedkeys(bobpub)
	println('${shr2pub}')

	println('-----')

	mut message := 'Hello world, this is my awesome message'
	message += message
	message += message
	message += message
	message += message

	h256 := sha256.hexhash(message)
	println('${h256}')
	println('${h256.len}')
	println('${sha256.sum(message.bytes())}')

	parsed := hex.decode(h256) or { panic(err) }
	println('${parsed}')
	println('${parsed.len}')

	//
	// signature (ecdca)
	//
	signed := alice.sign_data(message.bytes())
	println('${signed}')

	signed_hex := alice.sign_data_hex(message.bytes())
	println('${signed_hex}')
	println('${signed_hex.len}')

	signed_str := alice.sign_str(message)
	println('${signed_str}')
	println('${signed_str.len}')

	signed_str_hex := alice.sign_str_hex(message)
	assert signed_str_hex == '656699dde22d8b89d91070dee4fc8dba136172fb54e6de475024c40e4f8d5111562212c8976b5a4ccd530bdb7f40c5d9bd2cdeeec1473656566fbb9c4576ed8c'
	assert signed_str_hex.len == 128

	// instanciate alice with only her public key
	assert alicepub.verify_data(signed, message.bytes()) == true
	assert alicepub.verify_str_hex(signed_str_hex, message) == true
	assert alicepub.verify_str_hex(signed_str_hex, message + 's') == false

	//
	// signature (schnorr)
	//
	// schnorr_signed := alice.schnorr_sign_data(message.bytes())
	// println('${schnorr_signed}')

	// schnorr_signed_hex := alice.schnorr_sign_data_hex(message.bytes())
	// println('${schnorr_signed_hex}')

	// schnorr_signed_str := alice.schnorr_sign_str(message)
	// println('${schnorr_signed_str}')

	// schnorr_signed_str_hex := alice.schnorr_sign_str_hex(message)
	// println('${schnorr_signed_str_hex}')

	// println('${alicepub.schnorr_verify_data(schnorr_signed, message.bytes())}')
	// println('${alicepub.schnorr_verify_str(schnorr_signed_str, message)}')

	// // should fails, it's not the right signature method (ecdsa / schnorr)
	// println('${alicepub.verify_data(schnorr_signed, message.bytes())}')
	// println('${alicepub.verify_str(schnorr_signed_str, message)}')
}
