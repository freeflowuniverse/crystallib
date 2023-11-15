module base

import freeflowuniverse.crystallib.osal

// install base will return true if it was already installed
pub fn install() ! {
	println('platform prepare')
	pl := osal.platform()
	if !osal.done_exists('platform_prepare') {
		if pl == .osx {
			if !osal.cmd_exists('brew') {
				osal.execute_interactive('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"') or {
					return error('cannot install brew, something went wrong.\n${err}')
				}
			}
			if !osal.cmd_exists('clang') {
				osal.execute_silent('xcode-select --install') or {
					return error('cannot install xcode-select --install, something went wrong.\n${err}')
				}
			}
			println(' - OSX prepare')
			osal.execute_silent('
			brew install mc tmux git rsync curl tmux
			')!
		} else if pl == .ubuntu {
			println(' - Ubuntu prepare')
			osal.execute_silent('
			apt update
			apt install iputils-ping net-tools git rsync curl mc tmux libsqlite3-dev -y
			')!
		} else {
			panic('only ubuntu and osx supported for now')
		}
		osal.done_set('platform_prepare', 'OK')!
	}
	println('Platform already prepared')
}
