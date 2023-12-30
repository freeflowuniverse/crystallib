module vscode

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.vscode as vscodeinstaller
import os
import freeflowuniverse.crystallib.ui.console

@[params]
pub struct OpenArgs {
pub mut:
	path string
}

// if not specified will use current dir
pub fn open(args_ OpenArgs) ! {
	check()!
	mut args := args_
	if args.path == '' {
		args.path = os.getwd()
	}
	check()!
	if !os.exists(args.path) {
		return error('Cannot open Visual Studio Code: could not find path ${args.path}')
	}
	cmd3 := "open -a \"Visual Studio Code\" ${args.path}"
	osal.execute_interactive(cmd3)!
}

// check visual studio code is installed
pub fn exists() bool {
	return osal.cmd_exists('vscode')
}

pub fn check() ! {
	if exists() == false {
		vscodeinstaller.install()!
		if exists() == false {
			return error('Visual studio code is not installed.\nPlease see https://code.visualstudio.com/download')
		}
	}
}

// // install visual studio code as 'code' cmd in os
// pub fn cmd_install() ! {
// 	check()!
// 	source := '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code'
// 	osal.cmd_add(cmdname: 'code', source: source, symlink: true, reset: true)!
// }
