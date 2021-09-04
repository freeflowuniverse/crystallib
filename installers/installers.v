module installers


import os
import despiegk.crystallib.builder
import despiegk.crystallib.publisher_config
import despiegk.crystallib.process
import despiegk.crystallib.nodejs
import despiegk.crystallib.gittools

pub fn web(doreset bool, clean bool) ? {

	// println('INSTALLER:')
	if doreset {
		println(' - reset the full system')
		reset() or { return error(' ** ERROR: cannot reset. Error was:\n$err') }
	}
	base() or { return error(' ** ERROR: cannot prepare system. Error was:\n$err') }

	// sites_download( true) or {
	// 	return error(' ** ERROR: cannot get web & wiki sites. Error was:\n$err')
	// }
	mut n := nodejs.get() or { return error(' ** ERROR: cannot install nodejs. Error was:\n$err') }
	n.install() or { return error(' ** ERROR: cannot install nodejs. Error was:\n$err') }

	if clean {
		sites_cleanup([]) or { return error(' ** ERROR: cannot cleanup sites. Error was:\n$err') }
	}

	// make sure the config we are working with is refelected in ~/.publisher/config
	// update_config() or { return error(' ** ERROR: cannot copy config files to ~publisher/config. Error was:\n$err') }

	mut gt := gittools.new() or { return error('ERROR: cannot load gittools on web installer:$err') }
		
	gt.repo_get_from_url(url:"https://github.com/threefoldfoundation/threefold_data")? 
	
	sites_install([]) or { return error(' ** ERROR: cannot install sites. Error was:\n$err') }
}

pub fn base() ? {
	myconfig := publisher_config.get()
	base := myconfig.publish.paths.base

	mut node := builder.node_get(builder.NodeArguments{}) or {
		return error(' ** ERROR: cannot load node. Error was:\n$err')
	}
	node.platform_prepare() ?

	if !os.exists(base) {
		os.mkdir(base) or { return err }
	}

	// os.mkdir_all('$base/config') or { return err }

	println(' - installed base requirements')
}

pub fn reset() ? {
	myconfig := publisher_config.get()
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
	process.execute_silent(script) ?
	println(' -update done')
}

// pub fn update_config() ? {
// 	cfg := publisher_config.get()
// 	println(' - copying config files to ~/.publishtools/config')
// 	res := os.ls('.') ?
// 	for file in res {
// 		if !os.is_file(file) {
// 			continue
// 		}

// 		os.cp('./$file', '$conf.publish.paths.base/config/$file') ?
// 	}
// }
