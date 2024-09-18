module doctreemodel

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
mut:
	collection   &Collection  @[str: skip]
pub mut:
	name         string // received a name fix
	ext          string
	state        FileStatus
	//pages_linked []&Page // pointer to pages which use this file
	ftype        FileType
}

pub fn (file File) file_name() string {
	return '${file.name}.${file.ext}'
}

fn (mut file File) path() !pathlib.Path {
	return pathlib.file_get("${file.connection.path}/${file.name}.${file.ext}")!
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

pub fn (mut file File) copy(dest string) ! {
	mut dest2 := pathlib.get(dest)
	file.path.copy(dest: dest2.path, rsync: false) or {
		return error('Could not copy file: ${file.path.path} to ${dest} .\n${err}\n${file}')
	}
}
