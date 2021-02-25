module installers

import cli
import os
import builder
import myconfig
import process
import nodejs

pub fn main(cmd cli.Command) ? {
	cfg := myconfig.get() ?

	mut ourreset := false
	mut clean := false
	for flag in cmd.flags {
		if flag.name == 'reset' && flag.value.len > 0 {
			ourreset = true
		}
		if flag.name == 'clean' && flag.value.len > 0 {
			clean = true
		}
	}

	println('INSTALLER:')

	if ourreset {
		println(' - reset the full system')
		reset() or { return error(' ** ERROR: cannot reset. Error was:\n$err') }
	}
	base() or { return error(' ** ERROR: cannot prepare system. Error was:\n$err') }

	sites_download(cmd) or {
		return error(' ** ERROR: cannot get web & wiki sites. Error was:\n$err')
	}

	nodejs.install(cfg) or { return error(' ** ERROR: cannot install nodejs. Error was:\n$err') }

	if clean {
		sites_cleanup(cmd) or { return error(' ** ERROR: cannot cleanup sites. Error was:\n$err') }
	}

	sites_install(cmd) or { return error(' ** ERROR: cannot install sites. Error was:\n$err') }
}

pub fn base() ? {
	myconfig := myconfig.get() ?
	base := myconfig.paths.base

	mut node := builder.node_get({}) or {
		return error(' ** ERROR: cannot load node. Error was:\n$err')
	}
	node.platform_prepare() ?

	if !os.exists(base) {
		os.mkdir(base) or { return error(err) }
	}

	println(' - installed base requirements')
}

pub fn config_get(cmd cli.Command) ?myconfig.ConfigRoot {
	mut cfg := myconfig.get() ?
	for flag in cmd.flags {
		if flag.name == 'pull' && flag.value.len > 0 {
			cfg.pull = true
		}
		if flag.name == 'reset' && flag.value.len > 0 {
			cfg.reset = true
		}
	}
	if !os.exists(cfg.paths.code) {
		os.mkdir(cfg.paths.code) or { return error(err) }
	}
	return cfg
}

pub fn reset() ? {
	myconfig := myconfig.get() ?
	base := myconfig.paths.base
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
	rm -f /usr/local/bin/publishtools
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/crystaluniverse/publishtools/master/scripts/install.sh)"
	'
	process.execute_silent(script) ?
	println(' -update done')
}
