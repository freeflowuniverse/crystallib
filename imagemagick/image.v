module imagemagick

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.process
import os

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

fn (mut image Image) init_() ? {
	if image.size_kbyte == 0 {
		image.size_kbyte = image.path.size_kb() or {
			return error('cannot define size file in kb.\n$error')
		}
		image.path.normalize() or { panic('normalize: $error') }
	}
}

pub fn image_new(mut path pathlib.Path) ?Image {
	mut i := Image{
		path: path
	}
	// i.init_()?
	return i
}

// backupdir, put on empty if not used
pub fn image_downsize(mut path pathlib.Path, backupdir string) ?Image {
	mut image := image_new(mut path)?
	if path.is_link() {
		mut path_linked := path.getlink()?
		mut image_linked := image_new(mut path_linked)?
		image_linked.downsize(backupdir)?
		if image.path.path != image_linked.path.path {
			// means downsize worked, now we need to re-link
			image.path.delete()?
			image.path.path = image.path.path_dir() + '/' + image_linked.path.name()
			image.path = image_linked.path.link(mut image.path)?
		}
	} else {
		image.downsize(backupdir)?
	}
	return image
}

// will downsize to reasonable size based on x
pub fn (mut image Image) downsize(backupdir string) ? {
	if image.path.is_link() {
		return error('use image_downsize function if file is a link:\n$image')
	}
	image.init_()?
	if image.skip() {
		return
	}
	// $if debug{println(' - downsize $image.path')}
	if image.is_png() {
		image.identify_verbose()?
	} else {
		image.identify()?
	}
	// check in params
	// if backupdir != '' {
	// 	mut dest := image.path.backup_name_find('', backupdir) or {
	// 		return error('cannot find backupname for $image.path.path . \n$error')
	// 	}
	// 	image.path.copy(mut dest)?
	// }
	if image.size_kbyte > 600 && image.size_x > 2400 {
		image.size_kbyte = 0
		println('   - convert image resize 50%: $image.path.path')
		cmd := "convert '$image.path.path' -resize 50% '$image.path.path'"
		// TODO:
		process.execute_silent(cmd) or {
			return error('could not convert png to png --resize 50%.\n$cmd .\n$error')
		}
		// println(image)
		image.init_()?
	} else if image.size_kbyte > 600 && image.size_x > 1800 {
		image.size_kbyte = 0
		println('   - convert image resize 75%: $image.path.path')
		cmd := "convert '$image.path.path' -resize 75% '$image.path.path'"
		process.execute_silent(cmd) or {
			return error('could not convert png to png --resize 75%.\n$cmd \n$error')
		}
		image.init_()?
	}

	if image.is_png() {
		if image.size_kbyte > 600 && !image.transparent {
			path_dest := image.path.path_no_ext() + '.jpg'
			println('   - convert image jpg: $path_dest')
			cmd := "convert '$image.path.path' '$path_dest'"
			if os.exists(path_dest) {
				os.rm(path_dest)?
			}
			process.execute_silent(cmd) or {
				return error('could not convert png to jpg.\n$cmd \n$error')
			}
			if os.exists(image.path.path) {
				os.rm(image.path.path)?
			}
			image.path = pathlib.get(path_dest)
		}
	}
	// means we should not process next time, we do this by adding _ at end of name
	path_dest2 := image.path.path_get_name_with_underscore()
	image.init_()?
	// println('   - add _ at end of image: $path_dest2')
	if os.exists(path_dest2) {
		os.rm(path_dest2)?
	}
	os.mv(image.path.path, path_dest2)?
	image.path = pathlib.get(path_dest2)
}

fn (mut image Image) identify_verbose() ? {
	if image.size_y != 0 {
		// means was already done
		return
	}
	// println(' - identify: $image.path')
	out := process.execute_silent("identify -verbose '$image.path.path'") or {
		return error('Could not get info from image $image.path.path \nError:$err')
	}
	mut channel_stats := false
	// mut channel_state := false
	mut channel_alpha := false
	for line in out.split('\n') {
		mut line2 := line.trim(' ')
		if line2.starts_with('Channel statistics:') {
			channel_stats = true
			continue
		}
		// if line2.starts_with("Channel depth"){
		// if line2.starts_with("Alpha:"){
		// 	channel_state = true
		// 	continue
		// }
		if line2.starts_with('Alpha:') && channel_stats {
			channel_alpha = true
			continue
		}
		if channel_stats && (line2.starts_with('Channel') || line2.starts_with('Image')
			|| line2.starts_with('Histogram')) {
			// channel_state = false
			channel_stats = false
			channel_alpha = false
		}

		if channel_alpha {
			// looking for mean not 255
			// Alpha:
			//   min: 0  (0)
			//   max: 255 (1)	
			//	 mean: 20.2322 (0.079342)		
			if line2.starts_with('mean:') {
				mean := line2.all_after(':').all_before('(').trim(' ')
				if mean != '255' {
					image.transparent = true
				}
				channel_stats = false
				channel_alpha = false
			}
		}

		if line2.starts_with('Geometry') {
			line2 = line2.all_before('+')
			line2 = line2.all_after(':').trim(' ')
			if line2.contains('x') {
				image.size_x = line2.split('x')[0].int()
				image.size_y = line2.split('x')[1].int()
			}
		}
		if line2.starts_with('Resolution') {
			line2 = line2.all_after(':').trim(' ')
			if line2.contains('x') {
				image.resolution_x = line2.split('x')[0].int()
				image.resolution_y = line2.split('x')[1].int()
			}
		}
		if line2.starts_with('Transparent color') {
			line2 = line2.all_after(':').trim(' ')
			if line2 != 'none' {
				image.transparent = true
			}
		}
	}
	// if image.transparent {
	// 	println("   - TRANSPARANT")
	// }
}

fn (mut image Image) identify() ? {
	if image.size_y != 0 {
		// means was already done
		return
	}
	// println(' - identify: $image.path')
	mut out := process.execute_silent("identify -ping '$image.path.path'") or {
		return error('Could not get info from image, error:$err')
	}
	out = out.trim(' \n')
	splitted := out.split(' ')
	if splitted.len < 3 {
		println(out)
		panic('splitting did not work')
	}
	size_str := splitted[2]
	if !size_str.contains('x') {
		println(out)
		panic('error in parsing. $size_str')
	}
	image.size_x = size_str.split('x')[0].int()
	image.size_y = size_str.split('x')[1].int()
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
	if image.size_kbyte < 601 {
		// println("SMALLER  $image.path (size: $image.size_kbyte)")
		return true
	}
	return false
}
