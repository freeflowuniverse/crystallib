module imagemagick

import freeflowuniverse.crystallib.pathlib
import params
import freeflowuniverse.crystallib.process

pub fn installed_() bool {
	println(' - init imagemagick')
	out := process.execute_silent('convert -version') or { return false }
	if !out.contains('ImageMagick') {
		return false
	}
	return true
}

pub const installed = installed_()

fn init_magick() Images {
	out := process.execute_silent('convert -version') or {
		panic('Imagemagick probably not installed, error:$err')
	}
	if !out.contains('ImageMagick') {
		panic('Imagemagick probably not installed, could not find string ImageMagic but:\n$out')
	}
	mut images := Images{}
	return images
}

// scan a directory
pub fn scan(path_ string, mut params params.Params) params.Params {
	mut path := pathlib.get_dir(path_, false)?
	if !imagemagick.installed {
		panic('cannot scan because imagemagic not installed.')
	}
	// print(" - check $path.path")
	if path.name().starts_with('.') {
		// println(" FALSE")
		return false
	} else if path.name().starts_with('_') {
		// println(" FALSE")
		return false
	} else if path.name_no_ext().ends_with('_') {
		// println(" FALSE")
		return false
	} else if !path.is_image() {
		// println(" FALSE")
		return false
	}
	// println(" TRUE")
	return true
}

fn executor_imagemagic(mut path pathlib.Path, mut params params.Params) ?params.Params {
	if mut image := image_downsize(path) {
		params.kwarg_add(path.path, '$err')
	} else {
		params.kwarg_add(path.path, 'OK')
	}
	return params
}

struct ScanArgs {
	path      string
	backupdir string
}

// struct ScanArgs{
// 	path string //where to start from
// 	backupdir string //if you want a backup dir
// }
// will return params with OK and ERROR if it was not ok
pub fn scan(args ScanArgs) ? {
	mut path := pathlib.get_dir(args.path, false)?
	mut params := params.Params{}
	if args.backupdir != '' {
		params.kwarg_add('backupdir', args.backupdir)
	}
	params = path.scan(mut params, [filter_imagemagic], [executor_imagemagic])?
	return params
}
