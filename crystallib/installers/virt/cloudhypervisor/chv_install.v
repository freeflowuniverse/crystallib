module cloudhypervisor

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import os

@[params]
pub struct InstallArgs {
pub mut:
	reset     bool
	uninstall bool
}

pub fn install(args_ InstallArgs) ! {
	mut args := args_
	version := '38.0.0'

	if args.reset || args.uninstall {
		uninstall()!
	}
	console.print_header('install cloud hypervisor')

	base.install()!

	res := os.execute('${osal.profile_path_source_and()} cloud-hypervisor --version')
	if res.exit_code == 0 {
		r := res.output.split_into_lines().filter(it.contains('cloud-hypervisor'))
		if r.len != 1 {
			return error("couldn't parse cloud-hypervisor version, expected 'cloud hypervisor version' on 1 row.\n${res.output}")
		}

		v := texttools.version(r[0].all_after('ypervisor v'))
		// console.print_debug("version: ${v} ${texttools.version(version)}")
		if v < texttools.version(version) {
			args.reset = true
		}
	} else {
		args.reset = true
	}

	if args.reset {
		console.print_header('install cloud hypervisor')
		mut url := ''
		if osal.is_linux_arm() {
			url = 'https://github.com/cloud-hypervisor/cloud-hypervisor/releases/download/v${version}/cloud-hypervisor-static-aarch64'
		} else if osal.is_linux_intel() {
			url = 'https://github.com/cloud-hypervisor/cloud-hypervisor/releases/download/v${version}/cloud-hypervisor-static'
		} else {
			return error('unsuported platform for cloudhypervisor')
		}

		console.print_header('download ${url}')
		dest := osal.download(
			url: url
			minsize_kb: 4000
			reset: args.reset
			dest: '/tmp/cloud-hypervisor'
		)!
		console.print_debug('download cloudhypervisor done')
		osal.cmd_add(
			cmdname: 'cloud-hypervisor'
			source: '${dest.path}'
		)!
	}
}

pub fn uninstall() ! {
	panic('not implemented')
}
