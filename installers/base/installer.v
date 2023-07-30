module base

import freeflowuniverse.crystallib.builder
import process

// install base will return true if it was already installed
pub fn install(mut node builder.Node) ! {
	println(' - ${node.name}: platform prepare')
	if !node.done_exists('platform_prepare') {
		if node.platform == builder.PlatformType.osx {
			if !node.cmd_exists('brew') {
				process.execute_interactive('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"') or {
					return error('cannot install brew, something went wrong.\n${err}')
				}
			}
			if !node.cmd_exists('clang') {
				node.exec('xcode-select --install') or {
					return error('cannot install xcode-select --install, something went wrong.\n${err}')
				}
			}
			println(' - Ubuntu prepare')
			node.exec_silent('
			brew install mc tmux git rsync curl tmux
			')!
		} else if node.platform == builder.PlatformType.ubuntu {
			println(' - Ubuntu prepare')
			node.exec_silent('
			apt update
			apt install iputils-ping net-tools git rsync curl mc tmux -y
			')!
		} else {
			panic('only ubuntu and osx supported for now')
		}
		node.done_set('platform_prepare', 'OK')!
	}
	println(' - platform already prepared')
}
