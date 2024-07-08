module qemu

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
	mut version := '10.0.0'

	if args.uninstall {
		console.print_header('uninstall qemu')
		uninstall()!
		console.print_debug(' - ok')
	}

	res := os.execute('virsh -v')
	if res.exit_code == 0 {
		r := res.output.split_into_lines().filter(it.contains('virsh version'))
		if r.len != 1 {
			return error("couldn't virsh version, expected 'virsh version' on 1 row.\n${res.output}")
		}

		v := texttools.version(r[0])
		if v < texttools.version(version) {
			args.reset = true
		}
	} else {
		args.reset = true
	}

	if args.reset == false {
		return
	}

	console.print_header('install libvirt & qemu')
	base.install()!
	if osal.platform() in [.arch, .ubuntu] {
		osal.package_install('qemu,libvirt,qemu-common,qemu-img,qemu-system-arm,qemu-system-x86,qemu-tools,libguestfs')!
		osal.exec(cmd: 'systemctl start libvirtd && systemctl enable libvirtd')!
	} else {
		return error('can only install qemu on ubuntu & arch')
	}

	if exists()! {
		console.print_header(' - qemu exists check ok.')
	}
}

// @[params]
// pub struct ExtensionsInstallArgs {
// pub mut:
// 	extensions string
// 	default    bool = true
// }

pub fn exists() !bool {
	return osal.cmd_exists('qemu')
}

pub fn uninstall() ! {
	panic('not implemented')
}
