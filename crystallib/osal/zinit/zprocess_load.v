module zinit

import os
import freeflowuniverse.crystallib.osal

pub fn (mut zp ZProcess) load() ! {
	zp.status()!

	if !zp.zinit.path.file_exists(zp.name + '.yaml') {
		$if debug {
			print_backtrace()
		}
		return error('there should be a file ${zp.name}.yaml in /etc/zinit')
	}

	if zp.zinit.pathcmds.file_exists(zp.name) {
		// means we can load the special cmd
		mut pathcmd := zp.zinit.pathcmds.file_get(zp.name)!
		zp.cmd = pathcmd.read()!
	}
	if zp.zinit.pathtests.file_exists(zp.name) {
		// means we can load the special cmd
		mut pathtest := zp.zinit.path.file_get(zp.name)!
		zp.test = pathtest.read()!
	}

	mut pathyaml := zp.zinit.path.file_get_new(zp.name + '.yaml')!
	contentyaml := pathyaml.read()!

	// the parsing of the file is needed to find the info which we can't get from the zinit daemon

	mut st := ''
	for line in contentyaml.split_into_lines() {
		if line.starts_with('exec:') && zp.cmd.len == 0 {
			zp.cmd = line.split('exec:')[1].trim('\'" ')
		}
		if line.starts_with('test:') && zp.cmd.len == 0 {
			zp.test = line.split('test:')[1].trim('\'" ')
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
					_, after := line.split_once('-') or { panic('bug') }
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
					key, val := line.split_once('=') or { panic('bug') }
					zp.env[key.trim_space()] = val.trim_space()
				}
			}
		}
	}
}
