module doctree

import freeflowuniverse.crystallib.core.pathlib
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

@[heap]
pub struct File {
pub mut:
	collection     &Collection  @[str: skip]
	name         string // received a name fix
	path         pathlib.Path
	pathrel      string
	state        FileStatus
	pages_linked []&Page // pointer to pages which use this file
	ftype        FileType
}

fn (mut file File) init() {
	if file.path.is_image() {
		file.ftype = .image
	}

	file.name = file.path.name_fix_no_ext()

	path_rel := file.path.path_relative(file.collection.path.path) or {
		panic('cannot get relative path.\n${err}')
	}

	file.pathrel = path_rel.trim('/')
}

fn (mut file File) delete() ! {
	file.path.delete()!
}

fn (mut file File) mv(dest string) ! {
	mut desto := pathlib.get_dir(path: dest)! // will fail if dir doesn't exist
	os.mv(file.path.path, desto.path) or {
		return error('could not rename ${file.path.path} to ${desto.path} .\n${err}\n${file}')
	}
	// need to get relative path in, in relation to collection
	file.pathrel = desto.path_relative(file.collection.path.path)!
	file.path = desto
}

fn (mut file File) exists() !bool {
	return file.path.exists()
}

fn (mut file File) copy(dest string) ! {
	mut dest2 := pathlib.get(dest)
	file.path.copy(dest: dest2.path) or {
		return error('Could not copy file: ${file.path.path} to ${dest} .\n${err}\n${file}')
	}
}
