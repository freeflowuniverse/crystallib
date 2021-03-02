module digitaltwin

import os

pub fn (mut twin DigitalTwinME) sign(data []byte) []byte {
	// TODO: sign the data with private key
	return []byte{}
}

pub fn (mut twin DigitalTwinME) verify(data []byte) bool {
	// TODO: verify that data was signed by us
	return true
}
