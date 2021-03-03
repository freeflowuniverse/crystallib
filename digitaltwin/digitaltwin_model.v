module digitaltwin

import libsodium
// import despiegk.crystallib.redisclient

pub struct DigitalTwin {
pub:
	id int
}

pub struct DigitalTwinME {
pub:
	id int
}

struct DigitalTwinFactory {
pub mut:
	// who am I
	me      DigitalTwinME
	redis   &int // &redisclient.Redis // FIXME
	privkey libsodium.PrivateKey
	seed    []byte // not sure about security
}

pub fn (mut twin DigitalTwin) id() int {
	return twin.id
}

pub fn (mut twin DigitalTwinME) id() int {
	return twin.id
}
