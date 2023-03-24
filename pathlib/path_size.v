module pathlib

import os

pub fn (mut path Path) size_kb() !int {
	// println(" - filesize: $path.path")
	// TODO: needs to walk over directory
	path.check_exists()!
	if path.cat == .file {
		return (os.file_size(path.path) / 1000).str().int()
	} else {
		return error('only support files for now')
	}
}

pub fn (mut path Path) size() !f64 {
	// println(" - filesize: $path.path")
	path.check_exists()!
	return os.file_size(path.path)
}
