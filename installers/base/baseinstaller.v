module base

import builder
import process

// install base will return true if it was already installed
pub fn (mut i Installer) install() ? {
	mut node := i.node
	println(' - $node.name: platform prepare')
	if !node.done_exists('platform_prepare') {
		if node.platform == builder.PlatformType.osx {
			if !node.cmd_exists('brew') {
				process.execute_interactive('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"') or {
					return error('cannot install brew, something went wrong.\n$err')
				}
			}
			if !node.cmd_exists('clang') {
				node.exec('xcode-select --install') or {
					return error('cannot install xcode-select --install, something went wrong.\n$err')
				}
			}
		} else if node.platform == builder.PlatformType.ubuntu {
			println(' - Ubuntu prepare')

			for x in ['git', 'rsync', 'curl'] {
				if !node.cmd_exists(x) {
					node.package_install(name: x)?
				}
			}
		} else {
			panic('only ubuntu and osx supported for now')
		}
		node.done_set('platform_prepare', 'OK')?
	}
	println(' - platform already prepared')
}

// pub fn (mut i Installer) update() ? {
// 	mut node := i.node
// 	panic("to implement")
// 	node.done_set('update_crystaltools', 'OK')?
// }
