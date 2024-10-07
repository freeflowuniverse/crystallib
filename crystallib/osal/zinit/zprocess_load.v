module zinit

pub fn (mut zp ZProcess) load() ! {
	zp.status()!
	mut zinitobj := new()!

	if !zinitobj.path.file_exists(zp.name + '.yaml') {
		$if debug {
			print_backtrace()
		}
		return error('there should be a file ${zp.name}.yaml in /etc/zinit')
	}

	// if zinitobj.pathcmds.file_exists(zp.name) {
	// 	// means we can load the special cmd
	// 	mut pathcmd := zinitobj.pathcmds.file_get(zp.name)!
	// 	zp.cmd = pathcmd.read()!
	// }
	// if zinitobj.pathtests.file_exists(zp.name) {
	// 	// means we can load the special cmd
	// 	mut pathtest := zinitobj.path.file_get(zp.name)!
	// 	zp.test = pathtest.read()!
	// }
	if zinitobj.pathcmds.file_exists(zp.name) {
		// means we can load the special cmd
		mut pathcmd := zinitobj.pathcmds.file_get(zp.name)!
		zp.cmd = pathcmd.read()!
	}

	mut pathyaml := zinitobj.path.file_get_new(zp.name + '.yaml')!
	contentyaml := pathyaml.read()!

	// the parsing of the file is needed to find the info which we can't get from the zinit daemon

	mut st := ''
	for line in contentyaml.split_into_lines() {
		if line.starts_with('exec:') && zp.cmd.len == 0 {
			zp.cmd = line.split('exec:')[1].trim('\'" ')
		}
		if line.starts_with('test:') && zp.cmd.len == 0 {
			zp.cmd_test = line.split('test:')[1].trim('\'" ')
		}
		if line.starts_with('after:') {
			st = 'after'
			continue
		}
		if line.starts_with('env:') {
			st = 'env'
			continue
		}
		if st == 'after' {
			if line.trim_space() == '' {
				st = 'start'
			} else {
				line.trim_space().starts_with('-')
				{
					_, after := line.split_once('-') or {
						panic('bug in ${pathyaml} for line ${line}')
					}
					zp.after << after.to_lower().trim_space()
				}
			}
		}
		if st == 'env' {
			if line.trim_space() == '' {
				st = 'start'
			} else {
				line.contains('=')
				{
					key, val := line.split_once(':') or {
						panic('bug in ${pathyaml} for line ${line} for env')
					}
					zp.env[key.trim(' \'"')] = val.trim(' \'"')
				}
			}
		}
	}
}
