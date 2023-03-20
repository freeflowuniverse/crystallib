module pathlib

import os

//////////////FILE

// find file underneith dir path, if exists return True
pub fn (mut path Path) file_exists(tofind string) bool {
	if path.cat != Category.dir {
		return false
	}
	if os.exists('${path.path}/${tofind}') {
		if os.is_file('${path.path}/${tofind}') {
			return true
		}
	}
	return false
}

// is case insensitive
pub fn (mut path Path) file_exists_ignorecase(tofind string) bool {
	if path.cat != Category.dir {
		return false
	}
	files := os.ls(path.path) or { []string{} }
	if tofind.to_lower() in files.map(it.to_lower()) {
		file_path := os.join_path(path.path.to_lower(), tofind.to_lower())
		if os.is_file(file_path) {
			return true
		}
	}
	return false
}

// find file underneith path, if exists return as Path, otherwise error
pub fn (mut path Path) file_get(tofind string) !Path {
	if path.cat != Category.dir || !(path.exists()) {
		return error('is not a dir or dir does not exist: ${path.path}')
	}
	if path.file_exists(tofind) {
		file_path := os.join_path(path.path, tofind)
		return Path{
			path: file_path
			cat: Category.file
			exist: .yes
		}
	}
	return error('${tofind} is not in ${path.path}')
}

// get file, if not exist make new one
pub fn (mut path Path) file_get_new(tofind string) !Path {
	if path.cat != Category.dir || !(path.exists()) {
		return error('is not a dir or dir does not exist: ${path.path}')
	}
	mut p := path.file_get(tofind) or { return get_file('${path.path}/${tofind}', true)! }
	return p
}

//////////////LINK

// find link underneith path, if exists return True
// is case insensitive
pub fn (mut path Path) link_exists(tofind string) bool {
	if path.cat != Category.dir {
		return false
	}
	// TODO: need to check, if this is correct, make test
	if os.exists('${path.path}/${tofind}') {
		if os.is_link('${path.path}/${tofind}') {
			return true
		}
	}
	return false
}

// find link underneith path, if exists return True
// is case insensitive
pub fn (mut path Path) link_exists_ignorecase(tofind string) bool {
	if path.cat != Category.dir {
		return false
	}
	files := os.ls(path.path) or { []string{} }
	if tofind.to_lower() in files.map(it.to_lower()) {
		file_path := os.join_path(path.path.to_lower(), tofind.to_lower())
		if os.is_link(file_path) {
			return true
		}
	}
	return false
}

// find link underneith path, return as Path, can only be one
// tofind is part of link name
pub fn (mut path Path) link_get(tofind string) !Path {
	if path.cat != Category.dir || !(path.exists()) {
		return error('is not a dir or dir does not exist: ${path.path}')
	}
	if path.link_exists(tofind) {
		file_path := os.join_path(path.path, tofind)
		return Path{
			path: file_path
			cat: Category.linkfile
			exist: .yes
		}
	}
	return error('${tofind} is not in ${path.path}')
}

///////// DIR

// find dir underneith path, if exists return True
pub fn (mut path Path) dir_exists(tofind string) bool {
	if path.cat != Category.dir {
		return false
	}
	if os.exists('${path.path}/${tofind}') {
		if os.is_dir('${path.path}/${tofind}') {
			return true
		}
	}
	return false
}

// find dir underneith path, if exists return True
pub fn (mut path Path) dir_exists_ignorecase(tofind string) bool {
	if path.cat != Category.dir {
		return false
	}
	mut files := os.ls(path.path) or { []string{} }
	if tofind in files {
		dir_path := os.join_path(path.path, tofind)
		if os.is_dir(dir_path) {
			return true
		}
	}
	return false
}

// find dir underneith path, return as Path
pub fn (mut path Path) dir_get(tofind string) !Path {
	if path.cat != Category.dir || !(path.exists()) {
		return error('is not a dir or dir does not exist: ${path.path}')
	}
	if path.dir_exists(tofind) {
		dir_path := os.join_path(path.path, tofind)
		return Path{
			path: dir_path
			cat: Category.dir
			exist: .yes
		}
	}
	return error('${tofind} is not in ${path.path}')
}

// get file, if not exist make new one
pub fn (mut path Path) dir_get_new(tofind string) !Path {
	if path.cat != Category.dir || !(path.exists()) {
		return error('is not a dir or dir does not exist: ${path.path}')
	}
	mut p := path.dir_get(tofind) or { return get_dir('${path.path}/${tofind}', true)! }
	return p
}
