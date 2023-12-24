module doctree

import freeflowuniverse.crystallib.core.pathlib

pub struct PointerPath {
pub mut:
	pointer Pointer
	path    pathlib.Path
}

@[params]
pub struct PointerPathArgs {
pub mut:
	path           string
	path_normalize bool // if this is set, it means it will change the path so the filename is clean
	needs_to_exist bool // if set will check the file exists
}

// will return a pointer to filepath (needs to be a file, cannot be a dir)
pub fn pointerpath_new(args PointerPathArgs) !PointerPath {
	mut mypath := pathlib.get_file(path: args.path)!
	if args.needs_to_exist && mypath.exists() == false {
		return error('path ${args.path} needs to exist, when creating a pointer path.')
	}
	mut p := pointer_new(mypath.name())!

	mut pointerpath := PointerPath{
		pointer: p
		path: mypath
	}
	if args.path_normalize {
		// need to change to clean path
		pointerpath.path.path_normalize()!
	}
	return pointerpath
}

pub fn (p PointerPath) is_image() bool {
	return p.pointer.is_image()
}

pub fn (p PointerPath) is_file_video_html() bool {
	return p.pointer.is_file_video_html()
}
