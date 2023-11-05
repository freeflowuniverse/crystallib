module imagemagick

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.osal

fn installed0() bool {
	// println(' - init imagemagick')
	out := osal.execute_silent('convert -version') or { return false }
	if !out.contains('ImageMagick') {
		return false
	}
	return true
}

// singleton creation
const installed1 = installed0()

pub fn installed() bool {
	// println("imagemagick installed: $imagemagick.installed1")
	return imagemagick.installed1
}

// scan a directory
fn filter_imagemagic(mut path pathlib.Path, mut params_ paramsparser.Params) !bool {
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
	} else if !path.is_file() {
		// println(" FALSE")
		return false
	} else if !path.is_image_jpg_png() {
		return false
	}
	// println(" TRUE")
	return true
}

fn executor_imagemagic(mut path pathlib.Path, mut params_ paramsparser.Params) !paramsparser.Params {
	mut backupdir := ''
	if params_.exists('backupdir') {
		backupdir = params_.get('backupdir') or { panic(error) }
	}
	mut image := image_new(mut path)!
	if backupdir.len > 0 {
		image.downsize(backup: true, backup_dest: backupdir)!
	} else {
		image.downsize()!
	}
	return params_
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
pub fn scan(args ScanArgs) !paramsparser.Params {
	if !installed() {
		panic('cannot scan because imagemagic not installed.')
	}
	mut path := pathlib.get_dir(path: args.path)!
	mut params_ := paramsparser.Params{}
	if args.backupdir != '' {
		params_.kwarg_set('backup', args.backupdir)
	}
	params_ = path.scan(mut params_, [filter_imagemagic], [executor_imagemagic])!
	return params_
}
