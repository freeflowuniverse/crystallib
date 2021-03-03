module digitaltwin

import libsodium
import despiegk.crystallib.redisclient

pub struct DigitalTwin {
pub:
	id int
}

struct DigitalTwinFactory {
pub mut:
	// who am I
	me      DigitalTwinME
	redis   &redisclient.Redis
	privkey libsodium.PrivateKey
	signkey libsodium.SigningKey
	seed    []byte // not sure about security
}

pub struct DigitalTwinForeign {
pub mut:
	pubkey [32]byte
	verifkey libsodium.VerifyKey
}

pub fn (mut twin DigitalTwin) id() int {
	return twin.id
}

pub fn (mut twin DigitalTwinME) id() int {
	return twin.id
}
