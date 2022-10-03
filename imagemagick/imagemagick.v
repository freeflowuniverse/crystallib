module imagemagick

import freeflowuniverse.crystallib.pathlib
import params
import freeflowuniverse.crystallib.process

fn installed0() bool {
	println(' - init imagemagick')
	out := process.execute_silent('convert -version') or { return false }
	if !out.contains('ImageMagick') {
		return false
	}
	return true
}

// singleton creation
const installed1 = installed0()

pub fn installed() bool {
	return imagemagick.installed1
}

// scan a directory
fn filter_imagemagic(mut path pathlib.Path, mut params params.Params) ?bool {
	// print(" - check $path.path")
	// println(" ===== "+path.name_no_ext())
	if path.name().starts_with('.') {
		// println(" FALSE")
		return false
	} else if path.name().starts_with('_') {
		// println(" FALSE")
		return false
	} else if path.name_no_ext().ends_with('_') {
		// println(" FALSE")
		return false
	} else if path.is_file() && !path.is_image_jpg_png() {
		// println(" FALSE")
		return false
	}
	// println(" TRUE")
	return true
}

fn executor_imagemagic(mut path pathlib.Path, mut params params.Params) ?params.Params {
	mut backupdir := ''
	if params.exists('backupdir') {
		backupdir = params.get('backupdir') or { panic(error) }
	}
	image_downsize(mut path, backupdir)?
	// if mut _ := image_downsize(mut path, backupdir) {
	// 	println('** ERROR: could not downsize: $path.path \n$error')
	// 	params.kwarg_add(path.path, '$error')
	// } else {
	// 	params.kwarg_add(path.path, 'OK')
	// }
	return params
}

pub struct ScanArgs {
pub:
	path      string
	backupdir string
}

// struct ScanArgs{
// 	path string //where to start from
// 	backupdir string //if you want a backup dir
// }
// will return params with OK and ERROR if it was not ok
pub fn scan(args ScanArgs) ?params.Params {
	if !installed() {
		panic('cannot scan because imagemagic not installed.')
	}
	mut path := pathlib.get_dir(args.path, false)?
	mut params := params.Params{}
	if args.backupdir != '' {
		params.kwarg_add('backupdir', args.backupdir)
	}
	params = path.scan(mut params, [filter_imagemagic], [executor_imagemagic])?
	return params
}
