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

fn filter_imagemagic(mut path pathlib.Path, mut params_ paramsparser.Params) !bool {
	// println(" - check $path.path")
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
	} else if path.is_dir() {
		return true
	} else if !path.is_file() {
		// println(" FALSE")
		return false
	} else if !path.is_image_jpg_png() {
		return false
	}
	mut parent := path.parent()!
	if parent.file_exists('.done') {
		mut p := parent.file_get('.done')!
		c := p.read()!
		if c.contains(path.name()) {
			return false
		}
	}
	// println(" TRUE")
	return true
}

fn executor_imagemagic(mut path pathlib.Path, mut params_ paramsparser.Params) !paramsparser.Params {
	if path.is_dir() {
		return params_
	}
	println(' - image check ${path.path}')
	mut backupdir := ''
	if params_.exists('backupdir') {
		backupdir = params_.get('backupdir') or { panic(error) }
	}
	mut image := image_new(mut path)!
	mut redo := false
	if params_.exists('redo') {
		redo = true
	}
	mut convertpng := false
	if params_.exists('convertpng') {
		convertpng = true
	}
	if backupdir.len > 0 {
		image.downsize(backup: true, backup_dest: backupdir, redo: redo, convertpng: convertpng)!
	} else {
		image.downsize(redo: redo)!
	}
	return params_
}

pub struct DownsizeArgs {
pub:
	path       string
	backupdir  string
	redo       bool
	convertpng bool
}

// struct ScanArgs{
// 	path string //where to start from
// 	backupdir string //if you want a backup dir
// }
// will return params with OK and ERROR if it was not ok
pub fn downsize(args DownsizeArgs) !paramsparser.Params {
	if !installed() {
		panic('cannot scan because imagemagic not installed.')
	}
	mut path := pathlib.get_dir(path: args.path)!
	mut params_ := paramsparser.Params{}
	if args.backupdir != '' {
		params_.set('backup', args.backupdir)
	}
	if args.redo {
		params_.set('redo', '1')
	}

	if args.convertpng {
		params_.set('convertpng', '1')
	}

	params_ = path.scan(mut params_, [filter_imagemagic], [executor_imagemagic])!
	return params_
}
