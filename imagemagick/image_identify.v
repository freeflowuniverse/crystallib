module imagemagick

import freeflowuniverse.crystallib.process

fn (mut image Image) identify_verbose() ! {
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

fn (mut image Image) identify() ! {
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
