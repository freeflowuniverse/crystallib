module rclone

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
	version:="1.65.1"

	res := os.execute('source ${osal.profile_path()} && rclone version')
	if res.exit_code == 0 {

		r:=res.output.split_into_lines().filter(it.contains("rclone v"))
		if r.len != 1{
			return error("couldn't parse rclone version, expected 'rclone 0' on 1 row.\n$res.output")
		}

		v:=texttools.version(r[0].all_after("rclone"))
		if v<texttools.version(version) {
			args.reset = true
		}
	} else {
		args.reset = true
	}

	if args.reset == false {
		return
	}

	console.print_header('install rclone')

		mut url := ''
	if osal.is_linux_arm() {
		url = 'https://github.com/rclone/rclone/releases/download/v${version}/rclone-v${version}-linux-arm64.zip'
	} else if osal.is_linux_intel() {
		url = 'https://github.com/rclone/rclone/releases/download/v${version}/rclone-v${version}-linux-amd64.zip'		
	} else if osal.is_osx_arm() {
		url = 'https://github.com/rclone/rclone/releases/download/v${version}/rclone-v${version}-osx-arm64.zip'
	} else if osal.is_osx_intel() {
		url = 'https://github.com/rclone/rclone/releases/download/v${version}/rclone-v${version}-osx-amd64.zip'
	} else {
		return error('unsported platform')
	}

	mut dest := osal.download(
		url: url
		minsize_kb: 15000
		expand_file: "/tmp/rclone"
	)!

	// will find the one dir in the destination and move that one up 1 level
	dest.moveup_single_subdir()!

	mut binpath := dest.file_get('rclone')!

	// println(dest)

	osal.cmd_add(
		cmdname: 'rclone'
		source: binpath.path
	)!

	return
}
