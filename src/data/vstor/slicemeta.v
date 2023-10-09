module vstor

import hash.crc32

// the metadata as required for retrieving info from set of ZDB's
pub struct SliceMeta {
pub mut:
	zdbids      []u32 // list of ZDB's used = the position in VSTOR.zdbs
	zdbposition []u32 // the position in the ZDB (the key as u32)
	crc32       []u32 // crc32 of each part in the zdb
}

// check the health of a data object on the ZDB's
// if ok return true
fn (mut sm SliceMeta) verify() bool {
	// redis new command to ZDB, to allow verification of a part is needed
	// it checks the given CRC versus the data on the server
	// if e.g. 10 parts in a dataobject, there would be 10 redis calls
	// only if all 10 are ok, return true here
	return true
}
