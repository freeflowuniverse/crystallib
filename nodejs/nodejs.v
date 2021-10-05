module nodejs

import os
import builder
import process
import publisher_config

struct NodeJS{
pub mut:
	node builder.Node
	cfg &publisher_config.ConfigRoot
}

pub fn get()?NodeJS{
	mut cfg := publisher_config.get()
	mut n := builder.node_get(builder.NodeArguments{name:"main"})?
	return NodeJS{node:n, cfg:cfg}
}

pub fn (mut n NodeJS) install() ? {
	mut script := ''
	base := n.cfg.publish.paths.base
	nodejspath := n.cfg.nodejs.path

	n.node.platform_prepare() ?

	println(" - base dir: $base")
	println(" - nodejs dir: $nodejspath")

	if n.cfg.nodejs.nvm {
		if !os.exists('$base/nvm.sh') {
			script = "
			set -e
			rm -f $base/nvm.sh
			curl -s -o '$base/nvm.sh' https://raw.githubusercontent.com/nvm-sh/nvm/master/nvm.sh
			"
			process.execute_silent(script) or {
				println('cannot download nvm script.\n$err')
				exit(1)
			}
		}


		mut nodev := ""

		if n.cfg.nodejs.version == publisher_config.NodejsCat.latest{
			// nodev = "node"
			nodev = "$n.cfg.nodejs.versionnr"
		}else{
			// nodev = "--lts"
			nodev = "$n.cfg.nodejs.versionnr"
		}

		if !os.exists('$nodejspath/bin/node') {
			println(' - will install nodejs $n.cfg.nodejs.version (can take quite a while)')
			script = '
			set +e
			export NVM_DIR=$base
			source $base/nvm.sh
			nvm install $nodev
			npm install -g @gridsome/cli
			'

			process.execute_silent(script) or {
				println('cannot install nodejs.\n$err')
				exit(1)
			}

			n.npm_install('@gridsome/cli', true) ?

		}
	} else {
		if n.cfg.nodejs.version == publisher_config.NodejsCat.latest {
			n.node.package_install(name: 'node') ?
		} 

		if n.node.platform == builder.PlatformType.osx {
			n.node.package_install(name: 'node@14') ?
			// node.executor.exec('brew install $name') or {
			// 	return error('could not install package:$package.name\nerror:\n$err')
			// }
			// } else if node.platform == PlatformType.ubuntu {
			// 	node.executor.exec('apt install $name -y') or {
			// 		return error('could not install package:$package.name\nerror:\n$err')
			// 	}
		} else {
			panic('implement for other platforms')
		}

		n.npm_install('@gridsome/cli', true) ?
	}

	println(' - nodejs installed')

	
}

pub fn (mut n NodeJS) npm_install(name string,global bool) ? {
	mut script := ''

	base := n.cfg.publish.paths.base

	n.check()?

	if n.cfg.nodejs.nvm {
		script = 'source $base/nvm.sh\n'
	}

	if global {
		script += 'npm install -g $name'
	} else {
		script += 'npm install $name\n'
	}

	process.execute_stdout(script) or {
		return error('could not install npm package:$name\nerror:\n$err')
	}
}

fn (mut n NodeJS) check() ? {
	if !n.node.cmd_exists('npm') {
		return error('cannot find npm, please install the nodejs using nodejs.install')
	}
}

pub fn (mut n NodeJS) npm_install_all(path string) ? {

	base := n.cfg.publish.paths.base

	n.check()?

	if !os.exists(path) {
		return error("cannot find path: $path to do 'npm install' in")
	}
	mut script := ''


	if n.cfg.nodejs.nvm {
		script = 'source $base/nvm.sh\n'
	}

	// if global {
	// 	script += 'npm install -g $name'
	// } else {
	// 	script += 'npm install $name\n'
	// }

	process.execute_stdout(script) or {
		return error('could not do npm install:\n$err')
	}
}