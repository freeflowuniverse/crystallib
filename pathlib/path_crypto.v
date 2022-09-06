module pathlib

import crypto.sha256

// return sha256 hash of a file
pub fn (mut path Path) sha256() ?string {
	c := path.read()?
	return sha256.hexhash(c)
}
