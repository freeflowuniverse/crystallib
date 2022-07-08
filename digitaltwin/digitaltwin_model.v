module digitaltwin

import libsodium
import freeflowuniverse.crystallib.redisclient

pub struct DigitalTwin {
pub:
	id        int
	seed      string
	pubkey    [32]byte
	verifkey  libsodium.VerifyKey
	ipaddress string = '::1' // ipv6 localhost	
}

struct DigitalTwinFactory {
pub mut:
	// who am I
	me    DigitalTwinME
	redis &redisclient.Redis
	// my private & signing key
	privkey libsodium.PrivateKey
	signkey libsodium.SigningKey
	seed    []byte // not sure about security
}

pub fn (mut twin DigitalTwin) id() int {
	return twin.id
}
