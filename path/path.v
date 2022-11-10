module path

import os

pub struct Path {
pub mut:
	path     string
	exists   PathExists
	cat      Category
	absolute bool
}

pub enum Category {
	unknown
	file
	dir
	linkdir
	linkfile
}

pub enum PathExists {
	unknown
	yes
	no
}

// gets Path object, will check if it exists, is dir_file, ...
pub fn get(path string) Path {
	mut p2 := Path{
		path: path
	}
	p2.check()
	return p2
}

// check if path obj exists, is file, link, dir, ...
pub fn get_dir(path string, create bool) ?Path {
	mut p2 := get(path)
	if create && !p2.exists() {
		pp := p2.path_absolute()
		os.mkdir_all(pp) or { return error('cannot create path $pp') } // Make sure that all the needed paths created
		p2.check()
	}
	return p2
}

// get file path object, make sure the dir exists
pub fn get_file_dir_create(path string) ?Path {
	mut p2 := get(path)
	parent_ := p2.parent()?
	os.mkdir_all(parent_.path_absolute()) or { return error('cannot create path:$path') }
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
	return Path{
		path: path
		cat: Category.dir
		exists: PathExists.yes
	}
}

// will create dir obj, check if it exists, if not will give error
fn get_dir_exists(path string) ?Path {
	if !os.exists(path) {
		return error('cannot find dir: $path')
	}
	if !os.is_dir(path) {
		return error('cannot create new dir obj, because dir existed and was not dir type. $path')
	}
	return Path{
		path: path
		cat: Category.dir
		exists: PathExists.yes
	}
}

pub fn (mut path Path) size_kb() int {
	// println(" - filesize: $path.path")
	return (os.file_size(path.path) / 1000).str().int()
}

pub fn (mut path Path) size() f64 {
	// println(" - filesize: $path.path")
	return os.file_size(path.path)
}

pub fn (mut path Path) name() string {
	return os.base(path.path)
}

// full path of dir
pub fn (mut path Path) path_dir() string {
	return os.dir(path.path)
}

pub fn (mut path Path) name_no_ext() string {
	return path.name().all_before_last('.')
}

pub fn (mut path Path) path_no_ext() string {
	return path.path.all_before_last('.')
}

pub fn (mut path Path) name_ends_with_underscore() bool {
	return path.name_no_ext().ends_with('_')
}

// return a path which has name ending with _
pub fn (mut path Path) path_get_name_with_underscore() string {
	if path.name_ends_with_underscore() {
		return path.path
	} else {
		return path.path.all_before_last('.') + '_.' + path.extension()
	}
}
