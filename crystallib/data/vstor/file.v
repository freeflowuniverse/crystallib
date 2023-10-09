module vstor

import freeflowuniverse.crystallib.core.pathlib

// the metadata as required for retrieving info from set of ZDB's
// this is the metadata which needs to be kept, otherwise data cannot be retrieved
pub struct FileMeta {
mut:
	slices []SliceMeta
pub mut:
	name             string
	hash             string // blake 192
	compression_type CompressionType
	encryption_type  EncryptionType
}

enum CompressionType {
	nothing
	zlib
}

enum EncryptionType {
	nothing
	blowfish
}

// download file as specified to specified path
fn download(mut f FileMeta, path0 string) ! {
	mut path := pathlib.get(path0)
}
