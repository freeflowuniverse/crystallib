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

// only way how to get to a new file
// needs to process links
fn (mut site Site) file_new(mut p pathlib.Path) ? {
	if !p.exists() {
		return error('cannot find file for path in site: $p.path')
	}
	if p.name().starts_with("."){
		panic("should not start with . \n$p")
	}
	p.namefix()? // make sure its all lower case and name is proper
	mut ff := File{
		path: p
		site: &site
	}
	ff.init()
	site.files[ff.name] = ff
}

fn (mut file File) init() {
	file.name = file.path.name_no_ext().trim('_')
	if file.path.is_image() {
		file.ftype = .image
	}
	file.pathrel = file.path.path_relative(file.site.path.path).trim('/')
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
	file.pathrel = desto.path_relative(file.site.path.path)
	file.path = desto
}

pub fn (mut file File) exists() ?bool {
	return file.path.exists()
}
