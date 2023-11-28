module imagemagick

import freeflowuniverse.crystallib.core.pathlib

pub struct Image {
pub mut:
	path         pathlib.Path
	size_x       int
	size_y       int
	resolution_x int
	resolution_y int
	size_kbyte   int
	transparent  bool
}

pub fn (mut image Image) init_() ! {
	if image.size_kbyte == 0 {
		image.size_kbyte = image.path.size_kb() or {
			return error('cannot define size file in kb.\n${err}')
		}
		image.path.path_normalize() or { panic('normalize: ${err}') }
	}
}

pub fn image_new(mut path pathlib.Path) !Image {
	mut i := Image{
		path: path
	}
	// i.init_()!
	return i
}

pub fn (mut image Image) is_png() bool {
	if image.path.extension().to_lower() == 'png' {
		return true
	}
	return false
}

fn (mut image Image) skip() bool {
	if image.path.name_no_ext().ends_with('_') {
		return true
	}
	if image.size_kbyte < 500 {
		// println("SMALLER  $image.path (size: $image.size_kbyte)")
		return true
	}
	return false
}
