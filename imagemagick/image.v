module imagemagick

import pathlib
import process
import os

pub struct Image {
pub mut:
	path         path.Path
	size_x       int
	size_y       int
	resolution_x int
	resolution_y int
	size_kbyte   int
	transparent  bool
}

pub fn image_new(path0 string) ?Image {
	mut p := path.Path{
		path: path0
	}
	mut i := Image{
		path: p
	}
	i.init()?
	return i
}

pub fn image_downsize(path0 string) ?Image {
	mut image := image_new(path0)?
	image.downsize('', '')?
	return image
}

pub fn (mut image Image) init() ? {
	if image.size_kbyte == 0 {
		// println(" - $image.path.path")
		image.size_kbyte = image.path.size_kb()
		image.path.normalize()?
	}
}

pub fn (mut image Image) identify_verbose() ? {
	if image.size_y != 0 {
		// means was already done
		return
	}
	println(' - identify: $image.path.path')
	out := process.execute_silent("identify -verbose '$image.path.path'") or {
		return error('Could not get info from image, error:$err')
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

pub fn (mut image Image) identify() ? {
	if image.size_y != 0 {
		// means was already done
		return
	}
	println(' - identify: $image.path.path')
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

fn (mut image Image) is_png() bool {
	if image.path.extension().to_lower() == 'png' {
		return true
	}

	return false
}

fn (mut image Image) skip() bool {
	if image.path.name_no_ext().ends_with('_') {
		return true
	}
	if image.size_kbyte < 400 {
		// println("SMALLER  $image.path.path (size: $image.size_kbyte)")
		return true
	}
	return false
}

// will downsize to reasonable size based on x
fn (mut image Image) downsize(sourcedir string, backupdir string) ? {
	image.init()?
	if image.skip() {
		return
	}
	println(' - PROCESS DOWNSIZE $image.path.path')
	if image.is_png() {
		image.identify_verbose()?
	} else {
		image.identify()?
	}
	if backupdir != '' {
		mut dest := image.path.backup_name_find(sourcedir, backupdir)?
		image.path.copy(mut dest)?
	}

	if image.size_x > 2400 {
		image.size_kbyte = 0
		println('   - convert image resize 50%: $image.path.path')
		process.execute_silent("convert '$image.path.path' -resize 50% '$image.path.path'")?
		// println(image)
		image.init()?
	} else if image.size_kbyte > 300 && image.size_x > 1800 {
		image.size_kbyte = 0
		println('   - convert image resize 75%: $image.path.path')
		process.execute_silent("convert '$image.path.path' -resize 75% '$image.path.path'")?
		image.init()?
	}

	if image.is_png() {
		if image.size_kbyte > 400 && !image.transparent {
			path_dest := image.path.path_no_ext() + '.jpg'
			println('   - convert image jpg: $path_dest')
			process.execute_silent("convert '$image.path.path' '$path_dest'")?
			if os.exists(path_dest) {
				os.rm(image.path.path)?
			}
			image.path.path = path_dest
		}
	}
	// means we should not process next time, we do this by adding _ at end of name
	path_dest2 := image.path.path_get_name_with_underscore()
	println('    - add _ at end of image: $path_dest2')
	os.mv(image.path.path, path_dest2)?
	image.path.path = path_dest2
}
