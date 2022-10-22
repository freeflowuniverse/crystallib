module pathlib

import freeflowuniverse.crystallib.texttools
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

pub enum UYN {
	unknown
	yes
	no
}

// return absolute path
// careful symlinks will not be resolved
pub fn (path Path) absolute() string {
	mut p := path.path.replace('~', os.home_dir())
	return os.abs_path(p)
}

// return absolute path
// careful the symlinks will be followed !!!
pub fn (path Path) realpath() string {
	mut p := path.path.replace('~', os.home_dir())
	mut p2 := os.real_path(p)
	p2 = os.abs_path(p2)
	return p2
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
}

fn (mut path Path) check_exists() ? {
	if !path.exists() {
		return error('Path $path needs to exist, error')
	}
}

pub fn (mut path Path) name() string {
	return os.base(path.path)
}

// return name with all lowercase_special chars done and also no extension
pub fn (mut path Path) name_fix_no_underscore_no_ext() string {
	return texttools.name_fix_no_underscore_no_ext(path.name_no_ext())
}

// return name with all lowercase_special chars done but keep extension
pub fn (mut path Path) name_fix_keepext() string {
	return texttools.name_fix_keepext(path.name())
}

pub fn (mut path Path) name_fix_no_ext() string {
	return texttools.name_fix_no_ext(path.name())
}

// full path of dir
pub fn (mut path Path) path_dir() string {
	return os.dir(path.path)
}

pub fn (mut path Path) name_no_ext() string {
	mut name := path.name()
	if name.contains('.') {
		name = name.all_before_last('.')
	}
	if name == '' {
		return path.name()
	}
	return name
}

pub fn (mut path Path) path_no_ext() string {
	return path.path_dir() + '/' + path.name_no_ext()
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
