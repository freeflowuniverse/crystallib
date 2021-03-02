module digitaltwin

import os
import libsodium

pub fn (mut twin DigitalTwinFactory) sign(data []byte) []byte {
	println("[+] sign: signing data: $data")

	// result := libsodium.new_signing_key(twin.privkey.public_key.data, twin.privkey.public_key.data)
	// println(result)

	// TODO: sign the data with private key
	return []byte{}
}

pub fn (mut twin DigitalTwinFactory) verify(data []byte) bool {
	// TODO: verify that data was signed by us
	return true
}
