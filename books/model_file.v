module books

import pathlib
import os

pub enum FileStatus {
	unknown
	ok
	error
}

[heap]
pub struct File {
pub:
	name string // received a name fix
	site &Site  [str: skip]
pub mut: // pointer to site
	path         pathlib.Path
	pathrel      string
	state        FileStatus
	pages_linked []&Page      [str: skip] // pointer to pages which use this file
}

// only way how to get to a new file
pub fn (mut site Site) file_new(fpath string) ?File {
	mut p := pathlib.get_file(fpath, false)? // makes sure we have the right path
	if !p.exists() {
		return error('cannot find file for path in site: $fpath')
	}
	p.namefix()? // make sure its all lower case and name is proper
	mut ff := File{
		name: p.name()
		path: p
		pathrel: p.path_relative(site.path.path)
		site: &site
	}
	return ff
}

pub fn (mut file File) delete() ? {
	file.path.delete()?
}

pub fn (mut file File) mv(dest string) ? {
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
