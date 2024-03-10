module garage

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import os

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

pub fn install(args_ InstallArgs) ! {
	mut args := args_
	version := '0.9.3'

	panic("implement check version")
	res := os.execute('${osal.profile_path_source_and()} garage version')
	if res.exit_code == 0 {
		r := res.output.split_into_lines().filter(it.contains('garage 0'))
		if r.len != 1 {
			return error("couldn't parse garage version, expected 'garage 0' on 1 row.\n${res.output}")
		}

		v := texttools.version(r[0].all_before('compiled').all_after('garage'))
		if v < texttools.version(version) {
			args.reset = true
		}
	} else {
		args.reset = true
	}

	if args.reset == false {
		return
	}

	console.print_header('install garage')

	mut url := ''
	if osal.is_linux_arm() {
		url = 'https://garagehq.deuxfleurs.fr/_releases/v${version}/aarch64-unknown-linux-musl/garage'
	} else if osal.is_linux_intel() {
		
		url = 'https://garagehq.deuxfleurs.fr/_releases/v${version}/x86_64-unknown-linux-musl/garage'
	} else {
		return error('unsported platform')
	}

	mut dest := osal.download(
		url: url
		minsize_kb: 7000
		expand_file: '/tmp/garage'
	)!

	// println(dest)

	osal.cmd_add(
		cmdname: 'garage'
		source: dest.path
	)!

	return
}
