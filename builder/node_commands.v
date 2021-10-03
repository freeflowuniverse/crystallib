module builder

import process

// check command exists on the platform, knows how to deal with different platforms
pub fn (mut node Node) cmd_exists(cmd string) bool {
	_ := node.executor.exec('which $cmd') or {
		return false
	}
	return true
}

pub fn (mut node Node) exec_ok(cmd string) bool {
	//TODO: need to put in support for multiline text files
	node.executor.exec_silent(cmd) or {
		// see if it executes ok, if cmd not found is false
		return false
	}
	// println(e)
	return true
}

fn (mut node Node) platform_load() {
	println(' - platform load')
	if node.platform == PlatformType.unknown {
		if node.cmd_exists('sw_vers') {
			node.platform = PlatformType.osx
		} else if node.cmd_exists('apt') {
			node.platform = PlatformType.ubuntu
		} else if node.cmd_exists('apk') {
			node.platform = PlatformType.alpine
		} else {
			panic('only ubuntu, alpine and osx supported for now')
		}
	}
}

pub fn (mut node Node) platform_prepare() ? {
	println(' - $node.name: platform prepare')
	if node.done_exists("platform_prepare"){
		println("    $node.name: was already done")
		return
	}
	if node.platform == PlatformType.osx {
		if !node.cmd_exists('brew') {
			process.execute_interactive('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"') or {
				return error('cannot install brew, something went wrong.\n$err')
			}
		}
		if !node.cmd_exists('clang') {
			node.executor.exec('xcode-select --install') or {
				return error('cannot install xcode-select --install, something went wrong.\n$err')
			}
		}
	} else if node.platform == PlatformType.ubuntu {
		println(' - Ubuntu prepare')
		for x in ['mc', 'git', 'rsync', 'curl'] {
			if !node.cmd_exists(x) {
				node.package_install(name: x) ?
			}
		}
	} else {
		panic('only ubuntu and osx supported for now')
	}
	node.done_set("platform_prepare","OK")?
}

pub fn (mut node Node) package_install(package Package) ? {
	name := package.name
	if node.platform == PlatformType.osx {
		node.executor.exec('brew install $name') or {
			return error('could not install package:$package.name\nerror:\n$err')
		}
	} else if node.platform == PlatformType.ubuntu {
		node.executor.exec('apt install $name -y') or {
			return error('could not install package:$package.name\nerror:\n$err')
		}
	} else if node.platform == PlatformType.alpine {
		node.executor.exec('apk install $name') or {
			return error('could not install package:$package.name\nerror:\n$err')
		}
	} else {
		panic('only ubuntu, alpine and osx supported for now')
	}
}
