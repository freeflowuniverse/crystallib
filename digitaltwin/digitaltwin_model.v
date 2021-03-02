module digitaltwin

import libsodium
// import despiegk.crystallib.redisclient

pub struct DigitalTwin {
	id int
}

pub struct DigitalTwinME {
	id int
}

struct DigitalTwinFactory {
pub mut:
	// who am I
	me      DigitalTwinME
	redis   &int // &redisclient.Redis // FIXME
	privkey libsodium.PrivateKey
}

pub fn (mut twin DigitalTwin) id() int {
	return twin.id
}

pub fn (mut twin DigitalTwinME) id() int {
	return twin.id
}
