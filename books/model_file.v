module books

import freeflowuniverse.crystallib.pathlib
import os

pub enum FileStatus {
	unknown
	ok
	error
}

pub enum FileType {
	file
	image
}

[heap]
pub struct File {
pub:
	site &Site [str: skip]
pub mut: // pointer to site
	name         string // received a name fix
	path         pathlib.Path
	pathrel      string
	state        FileStatus
	pages_linked []&Page      [str: skip] // pointer to pages which use this file
	ftype        FileType
}

fn (mut file File) init() {
	if file.path.is_image() {
		file.name = file.path.name_fix_no_underscore_no_ext()
		file.ftype = .image
	} else {
		file.name = file.path.name_fix_no_underscore()
	}
	file.pathrel = file.path.path_relative(file.site.path.path).trim('/')?
}

pub fn (mut file File) delete() ? {
	file.path.delete()?
}

fn (mut file File) mv(dest string) ? {
	os.mkdir_all(os.dir(dest))?
	mut desto := pathlib.get_file_dir_create(dest)?
	os.mv(file.path.path, desto.path) or {
		return error('could not rename $file.path.path to $desto.path .\n$err\n$file')
	}
	// need to get relative path in, in relation to site
	file.pathrel = desto.path_relative(file.site.path.path)?
	file.path = desto
}

pub fn (mut file File) exists() ?bool {
	return file.path.exists()
}
