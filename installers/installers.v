module installers

import os
import builder
import publisher_config
import process
// import nodejs
// import gittools

pub fn base() ? {
	myconfig := publisher_config.get()?
	base := myconfig.publish.paths.base

	mut node := builder.node_new(builder.NodeArguments{ name: 'local' }) or {
		return error(' ** ERROR: cannot load node. Error was:\n$err')
	}
	node.platform_prepare()?

	if !os.exists(base) {
		os.mkdir(base) or { return err }
	}

	// os.mkdir_all('$base/config') or { return err }

	println(' - installed base requirements')
}

pub fn reset() ? {
	myconfig := publisher_config.get()?
	base := myconfig.publish.paths.base
	assert base.len > 10 // just to make sure we don't erase all
	script := '
	set -e
	rm -rf $base
	'
	process.execute_silent(script) or {
		println('** ERROR: cannot reset the system.\n$err')
		exit(1)
	}
	println(' - removed the ~/.publishtools')
}

pub fn publishtools_update() ? {
	script := '
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/crystaluniverse/publishtools/development/scripts/install.sh)"
	'
	process.execute_silent(script)?
	println(' -update done')
}

// pub fn update_config() ? {
// 	cfg := publisher_config.get()?
// 	println(' - copying config files to ~/.publishtools/config')
// 	res := os.ls('.') ?
// 	for file in res {
// 		if !os.is_file(file) {
// 			continue
// 		}

// 		os.cp('./$file', '$conf.publish.paths.base/config/$file') ?
// 	}
// }
