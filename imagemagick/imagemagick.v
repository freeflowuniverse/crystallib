module imagemagick

import os
import pathlib
import process

pub struct Images {
pub mut:
	images []Image
	status ImagesStatus
}

pub enum ImagesStatus {
	init
	loaded
}

pub fn installed_() bool {
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
		panic('Imagemagick probably not installed, could not find string ImageMahic but:\n$out')
	}
	mut images := Images{}
	return images
}

// const cache = init_magick()

// pub fn new() &Images {
// 	return &imagemagick.cache
// }

// pub fn add(pathin string) &Images {
// 	mut path2 := pathlib.get_dir(pathin,false)
// 	mut images := new()
// 	images.load(path2) or {panic("cannot load images")}
// 	return images
// }

// fn (mut images Images) check() ? {
// 	if images.status == ImagesStatus.loaded {
// 		return
// 	}
// 	images.load() ?
// }

pub struct ImageFindArgs {
pub mut:
	filter string
	force  bool
	show   bool
}

// pub fn (mut images Images) repos_get(args ImageFindArgs) []GitRepo  {
// 	mut res := []GitRepo{}
// 	for mut g in images.repos {
// 		relpath := g.path_relative()
// 		if args.filter != "" {
// 			if relpath.contains(args.filter){
// 				// println("$g.addr.name")
// 				res << g
// 			}		
// 		}else{
// 			res << g
// 		}
// 	}

// 	return res
// }

// pub fn (mut images Images) repos_print(args ImageFindArgs)  {
// 	mut r := [][]string{}
// 	for mut g in images.repos_get(args){
// 		// println(g)
// 		changed:=g.changes()or {panic("issue in repo changes. $err")}
// 		if changed{
// 			r << ["- ${g.path_relative()}","$g.addr.branch","CHANGED"]
// 		}else{
// 			// println( " - ${g.path_relative()} - $g.addr.branch")
// 			r << ["- ${g.path_relative()}","$g.addr.branch",""]
// 		}
// 	}
// 	texttools.print_array2(r,"  ",true)
// }

// pub fn (mut images Images) list(args ImageFindArgs)? {
// 	texttools.print_clear()
// 	println(" #### overview of repositories:")
// 	println("")
// 	images.repos_print(args)
// 	println("")
// }

// the factory for getting the images
// git is checked uderneith $/code
pub fn (mut images Images) add(p string) ? {
	// mut root2:=""
	// if 'DIR_CODE' in os.environ() {
	// 	dir_ct := os.environ()['DIR_CODE']
	// 	root2 = '$dir_ct/'
	// } else {
	// 	root2 = '$os.home_dir()/code/'
	// 	if !os.exists(root2) {
	// 		os.mkdir_all(root2) ?
	// 	}
	// }

	// check if there are other arguments used as the ones loaded
	// if images.status == ImagesStatus.loaded {
	// 	return
	// }

	mut p2 := p
	if p2 == '' {
		p2 = os.getwd()
	}

	// print_backtrace()
	println(' - SCAN IMAGES FOR $p ')

	mut done := []string{}

	images.load_recursive(p2, mut done)?
	images.status = ImagesStatus.loaded

	println(' - SCAN done')
}

fn (mut images Images) load_recursive(p string, mut done []string) ? {
	items := os.ls(p) or { return error('cannot load images because cannot find $p') }
	mut pathnew := ''
	for item in items {
		pathnew = os.join_path(p, item)
		// CAN DO THIS LATER IF NEEDED
		// if pathnew in done{
		// 	continue
		// }
		// done << pathnew
		if os.is_dir(pathnew) {
			// println(" - $pathnew")		
			if item.starts_with('.') {
				continue
			}
			// if item.starts_with('_') {
			// 	continue
			// }
			images.load_recursive(pathnew, mut done)?
			continue
		}
		mut p2 := pathlib.get_file(pathnew, false)?
		// println(p2)
		if p2.is_image() {
			// println(p2.path)
			mut i := Image{
				path: p2
			}
			i.init()?
			images.images << i
		}
	}
}
