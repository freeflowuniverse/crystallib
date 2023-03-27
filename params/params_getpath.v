module params

import os
// will get path and check it exists

pub fn (params &Params) get_path(key string) !string {
	path := params.get(key)!

	if !os.exists(path) {
		return error('Cannot find path: ${key}')
	}

	return path
}

// will get path and check it exists if not will create
pub fn (params &Params) get_path_create(key string) !string {
	path := params.get(key)!

	if !os.exists(path) {
		os.mkdir_all(path)!
	}

	return path
}
