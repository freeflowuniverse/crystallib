module imagemagick

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal
import os

[params]
pub struct DownsizeArgs {
	backup      bool
	backup_root string
	backup_dest string
}

// // backupdir, put on empty if not used
// pub fn image_downsize(args DownsizeArgs) !Image {
// 	mut image := image_new(mut path)!
// 	if path.is_link() {
// 		mut path_linked := path.getlink()!
// 		mut image_linked := image_new(mut path_linked)!
// 		pathlib.BackupArg{
// 			dest:backupdir
// 		}
// 		image_linked.downsize(backupdir)!
// 		if image.path.path != image_linked.path.path {
// 			// means downsize worked, now we need to re-link
// 			image.path.delete()!
// 			image.path.path = image.path.path_dir() + '/' + image_linked.path.name()
// 			image.path = image_linked.path.link(image.path.path, true)!
// 		}
// 	} else {
// 		image.downsize(backupdir)!
// 	}
// 	return image
// }

// will downsize to reasonable size based on x
pub fn (mut image Image) downsize(args DownsizeArgs) ! {
	if image.path.is_link() {
		return error('cannot downsize if path is link.\n${image}')
	}
	image.init_()!
	if image.skip() {
		return
	}
	// $if debug{println(' - downsize $image.path')}
	if image.is_png() {
		image.identify_verbose()!
	} else {
		image.identify()!
	}
	// check in params
	if args.backup {
		image.path.backup(dest: args.backup_dest, root: args.backup_root)!
	}
	if image.size_kbyte > 600 && image.size_x > 2400 {
		image.size_kbyte = 0
		println('   - convert image resize 50%: ${image.path.path}')
		cmd := "convert '${image.path.path}' -resize 50% '${image.path.path}'"
		// TODO:
		osal.execute_silent(cmd) or {
			return error('could not convert png to png --resize 50%.\n${cmd} .\n${error}')
		}
		// println(image)
		image.init_()!
	} else if image.size_kbyte > 600 && image.size_x > 1800 {
		image.size_kbyte = 0
		println('   - convert image resize 75%: ${image.path.path}')
		cmd := "convert '${image.path.path}' -resize 75% '${image.path.path}'"
		osal.execute_silent(cmd) or {
			return error('could not convert png to png --resize 75%.\n${cmd} \n${error}')
		}
		image.init_()!
	}

	if image.is_png() {
		if image.size_kbyte > 600 && !image.transparent {
			path_dest := image.path.path_no_ext() + '.jpg'
			println('   - convert image jpg: ${path_dest}')
			cmd := "convert '${image.path.path}' '${path_dest}'"
			if os.exists(path_dest) {
				os.rm(path_dest)!
			}
			osal.execute_silent(cmd) or {
				return error('could not convert png to jpg.\n${cmd} \n${error}')
			}
			if os.exists(image.path.path) {
				os.rm(image.path.path)!
			}
			image.path = pathlib.get(path_dest)
		}
	}
	// means we should not process next time, we do this by adding _ at end of name
	// path_dest2 := image.path.path_get_name_with_underscore()
	// image.init_()!
	// // println('   - add _ at end of image: $path_dest2')
	// if os.exists(path_dest2) {
	// 	os.rm(path_dest2)!
	// }
	// os.mv(image.path.path, path_dest2)!
	// image.path = pathlib.get(path_dest2)

	parent:=path.parent()!
	p:=parent.file_get_new(".done")!
	c:=p.read()!
	if c.contains(path.name()){
		panic("bug")
	}
	c+="${path.name()}\n"
	p.write(c)!
}
