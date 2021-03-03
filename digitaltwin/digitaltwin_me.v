module digitaltwin

import libsodium

struct DigitalTwinME {
	id        int
	seed      string
	pubkey    string
	ipaddress string = '::1' // ipv6 localhost
}

pub fn (mut twin DigitalTwinFactory) sign(data string) []byte {
	println('[+] sign: signing data: $data')

	sk := libsodium.generate_signing_key_seed(twin.seed.data)

	signed := sk.sign_string(data)
	println(signed)
	println(sk.verify_key.verify_string(signed))

	return signed.bytes()
}

pub fn (mut twin DigitalTwinFactory) verify(data []byte) (bool, string) {
	println('[+] sign: signing data: $data')

	sk := libsodium.generate_signing_key_seed(twin.seed.data)

	println(sk)

	valid, message := sk.verify_key.verify(data)
	println(valid)
	println(message)

	return valid, string(message)
}
