module pathlib

import os

// gets Path object, will check if it exists, is dir_file, ...
pub fn get(path_ string) Path {
	mut path:=path_
	if path.contains("~"){
		path=path.replace("~",os.home_dir())
	}
	mut p2 := Path{
		path: path
	}
	p2.check()
	return p2
}

pub fn get_no_check(path string) Path {
	mut p2 := Path{
		path: path
	}
	return p2
}

// get a directory
pub fn get_dir(path string, create bool) ?Path {
	mut p2 := get(path)
	if !p2.is_dir() {
		return error('Path $path is not a dir.')
	}
	if create && !p2.exists() {
		os.mkdir_all(p2.absolute()) or { return error('cannot create path $p2') } // Make sure that all the needed paths created
	}
	p2.check()
	return p2
}

// get file path object, make sure the dir exists
pub fn get_file_dir_create(path string) ?Path {
	mut p2 := get(path)
	mut parent_ := p2.parent()?
	os.mkdir_all(parent_.absolute()) or { return error('cannot create path:$path') }
	p2.check()
	return p2
}

pub fn get_file(path string, create bool) ?Path {
	mut p2 := get(path)
	if create && !p2.exists() {
		parent_ := p2.parent()?
		os.mkdir_all(parent_.path) or { return error('cannot create path:$path') }
		os.write_file(path, '') or { return error('cannot create empty file:$path') }
		p2.check()
	}
	return p2
}

// will create a new empty dir
// CAREFULL: if it exists, will delete
fn new_dir_empty(path string) ?Path {
	if os.exists(path) && !os.is_dir_empty(path) {
		os.rmdir_all(path)? // delete dir with its content
	}
	os.mkdir_all(path)? // create dir and make sure it is empty dir
	mut p := Path{
		path: path
		cat: Category.dir
	}
	p.check()
	return p
}

// will create dir obj, check if it exists, if not will give error
fn get_dir_exists(path string) ?Path {
	if !os.exists(path) {
		return error('cannot find dir: $path')
	}
	if !os.is_dir(path) {
		return error('cannot create new dir obj, because dir existed and was not dir type. $path')
	}
	mut p := Path{
		path: path
		cat: Category.dir
	}
	p.check()
	return p
}
