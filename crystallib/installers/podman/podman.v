module podman

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
	// base.install()!
	if args.reset || args.uninstall{
		console.print_header('uninstall podman')
		uninstall()!
		println(" - ok")
		if args.uninstall{
			return 
		}		
	}
	console.print_header('package_install install podman')
	if !args.reset && osal.done_exists('install_podman') && exists()! {
		println(" - already installed")
		return
	}
	mut url:=""
	mut dest:='/tmp/podman.pkg'
	if osal.platform() == .osx{
		if osal.cputype() == .arm {
			url = 'https://github.com/containers/podman/releases/download/v4.8.2/podman-installer-macos-arm64.pkg'
		} else {
			url = 'https://github.com/containers/podman/releases/download/v4.8.2/podman-installer-macos-amd64.pkg'
		}
	} else if osal.platform() in [.alpine, .arch, .ubuntu]  {
		if osal.cputype() == .arm {
			url = 'https://github.com/containers/podman/releases/download/v4.8.2/podman-remote-static-linux_arm64.tar.gz'
		} else {
			url = 'https://github.com/containers/podman/releases/download/v4.8.2/podman-remote-static-linux_amd64.tar.gz'
		}
		dest='/tmp/podman.tar.gz'
	}
	console.print_header('download ${url}')
	osal.download(
		url: url
		minsize_kb: 75000
		reset: args.reset
		dest: dest
	)!

	if osal.platform() == .osx{
		cmd:="
		sudo installer -pkg ${dest} -target /
		"
		osal.exec(cmd:cmd)!
		println(" - pkg installed.")
	}else{
		panic("implement")
	}

	if exists()!{
		println(" - exists check ok.")
	}

	osal.done_set('install_podman', 'OK')!
}


@[params]
pub struct ExtensionsInstallArgs {
pub mut:
	extensions string
	default    bool = true
}

pub fn exists() !bool {
	return osal.cmd_exists('podman')
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

