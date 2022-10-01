module pathlib

import os

[heap]
pub struct Path {
pub mut:
	path  string
	cat   Category
	exist UYN
}

pub enum Category {
	unknown
	file
	dir
	linkdir
	linkfile
}

enum UYN {
	unknown
	yes
	no
}

// return absolute path
// careful symlinks will not be resolved
pub fn (path Path) absolute() string {
	mut p := path.path.replace('~', os.home_dir())
	if ! path.is_link(){
		//is not a link so we can return, will not resolve the links
		return os.real_path(p)
	}
	return os.resource_abs_path(p)
}

// return absolute path
// careful the symlinks will be followed !!!
pub fn (path Path) realpath() string {
	mut p := path.path.replace('~', os.home_dir())
	return os.real_path(p)
}


// check the inside of pathobject, is like an init function
pub fn (mut path Path) check() {
	// println(path)
	if os.exists(path.path) {
		path.exist = .yes
		if os.is_file(path.path) {
			if os.is_link(path.path) {
				path.cat = Category.linkfile
			} else {
				path.cat = Category.file
			}
		} else if os.is_dir(path.path) {
			if os.is_link(path.path) {
				path.cat = Category.linkdir
			} else {
				path.cat = Category.dir
			}
		} else {
			panic('cannot define type: $path.path, is bug')
		}
	} else {
		path.exist = .no
	}
	println(path)
}

fn (mut path Path) check_exists() ? {
	if !path.exists() {
		return error('Path $path needs to exist, error')
	}
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

// pub fn (mut path Path) str() string {
// 	return 'path: $path.path'
// }
