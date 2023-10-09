module osal

import os

pub fn file_write(path string, text string) ! {
	return os.write_file(path, text)
}

pub fn file_read(path string) !string {
	return os.read_file(path)
}

// remove all if it exists
pub fn dir_ensure(path string) ! {
	if !os.exists(path) {
		os.mkdir_all(path)!
	}
}

// remove all if it exists
pub fn dir_delete(path string) ! {
	if os.exists(path) {
		return os.rmdir_all(path)
	}
}

// remove all if it exists
// and then (re-)create
pub fn dir_reset(path string) ! {
	os.rmdir_all(path)!
	os.mkdir_all(path)!
}
