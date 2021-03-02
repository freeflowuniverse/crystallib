module digitaltwin

import libsodium

pub fn (mut twin DigitalTwinFactory) sign(data string) []byte {
	println("[+] sign: signing data: $data")

	sk := libsodium.generate_signing_key_seed(twin.seed.data)

	signed := sk.sign_string(data)
	println(signed)
	println(sk.verify_key.verify_string(signed))

	return signed.bytes()
}

pub fn (mut twin DigitalTwinFactory) verify(data []byte) bool {
	println("[+] sign: signing data: $data")

	sk := libsodium.generate_signing_key_seed(twin.seed.data)

	signed := sk.verify_key.verify(data)
	println(signed)

	return signed
}
