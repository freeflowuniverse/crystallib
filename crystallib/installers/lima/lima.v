module lima

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.ui.console

import os
@[params]
pub struct InstallArgs {
pub mut:
	reset bool
	uninstall bool
}

pub fn install(args_ InstallArgs) ! {
	mut args:=args_

	if args.reset || args.uninstall{
		console.print_header('uninstall lima')
		uninstall()!
		println(" - ok")
		if args.uninstall{
			return 
		}		
	}
	console.print_header('package_install install lima')
	if !args.reset && osal.done_exists('install_lima') && exists()! {
		println(" - already installed")
		return
	}
	mut url:=""
	mut dest:='/tmp/lima.tar.gz'
	mut dest_on_os:='${os.home_dir()}/hero/'
	if osal.platform() == .osx{
		if osal.cputype() == .arm {
			url = 'https://github.com/lima-vm/lima/releases/download/v0.19.1/lima-0.19.1-Darwin-arm64.tar.gz'
		} else {
			url = 'https://github.com/lima-vm/lima/releases/download/v0.19.1/lima-0.19.1-Darwin-x86_64.tar.gz'
		}
	} else if osal.platform() in [.alpine, .arch, .ubuntu]  {
		if osal.cputype() == .arm {
			url = 'https://github.com/lima-vm/lima/releases/download/v0.19.1/lima-0.19.1-Linux-aarch64.tar.gz'
		} else {
			url = 'https://github.com/lima-vm/lima/releases/download/v0.19.1/lima-0.19.1-Linux-x86_64.tar.gz'
		}
		dest_on_os="/"
	}
	console.print_header('download ${url}')
	osal.download(
		url: url
		minsize_kb: 45000
		reset: args.reset
		dest: dest
		expand_file: '/tmp/download/lima'
	)!


	cmd := "
	rsync -rav /tmp/download/lima/ ${dest_on_os}
	"
	osal.exec(cmd:cmd)!

	// if exists()!{
	// 	println(" - exists check ok.")
	// }

	// osal.done_set('install_lima', 'OK')!
}


@[params]
pub struct ExtensionsInstallArgs {
pub mut:
	extensions string
	default    bool = true
}

pub fn exists() !bool {
	return osal.cmd_exists('lima')
}

pub fn uninstall() ! {
	cmd:="
	// # Quit Google Chrome
	// osascript -e 'quit app \"Google Chrome\"'

	// # Wait a bit to ensure Chrome has completely quit
	// sleep 2

	"
	osal.exec(cmd:cmd)!
}

