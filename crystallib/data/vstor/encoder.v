module vstor

struct ObjectParts {
	data [][]u8
	// data [][]u8
}

fn encode(data []u8, dataparts u8, parityparts u8) !DataObject {
	// redis new command to ZDB, to allow verification of a part is needed
	// it checks the given CRC versus the data on the server
	// if e.g. 10 parts in a dataobject, there would be 10 redis calls
	// only if all 10 are ok, return true here
}

// once we know that an object is broken we need to re-encode
fn (mut do DataObject) repair() bool {
	// redis new command to ZDB, to allow verification of a part is needed
	// it checks the given CRC versus the data on the server
	// if e.g. 10 parts in a dataobject, there would be 10 redis calls
	// only if all 10 are ok, return true here
}
