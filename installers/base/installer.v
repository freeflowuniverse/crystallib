module base
import freeflowuniverse.crystallib.osal

import process

// install base will return true if it was already installed
pub fn install() ! {
	println('platform prepare')
	if !osal.done_exists('platform_prepare') {
		if osal.platform() == builder.PlatformType.osx {
			if !osal.cmd_exists('brew') {
				osal.execute_interactive('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"') or {
					return error('cannot install brew, something went wrong.\n${err}')
				}
			}
			if !osal.cmd_exists('clang') {
				osal.exec_silent('xcode-select --install') or {
					return error('cannot install xcode-select --install, something went wrong.\n${err}')
				}
			}
			println(' - OSX prepare')
			osal.exec_silent('
			brew install mc tmux git rsync curl tmux
			')!
		} osal.platform() == builder.PlatformType.ubuntu {
			println(' - Ubuntu prepare')
			osal.exec_silent('
			apt update
			apt install iputils-ping net-tools git rsync curl mc tmux -y
			')!
		} else {
			panic('only ubuntu and osx supported for now')
		}
		osal.done_set('platform_prepare', 'OK')!
	}
	println('Platform already prepared')
}
