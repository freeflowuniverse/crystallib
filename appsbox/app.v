module appsbox

import os

[heap]
pub interface App {
mut:
	instance AppInstance
	name string // binaries in ~/hub3/bin related to this app
	start() ?
	stop() ?
	install(bool) ?
	build() ?
	check() ?bool
}

[heap]
pub struct AppInstance {
pub mut:
	name string
	// binaries in ~/hub3/bin related to this app
	bins []string
	// other paths related to this app
	paths          []string
	tcpports       []int
	unixsocketpath string
}

pub fn (mut app AppInstance) exists() bool {
	mut f := factory
	for bin in app.bins {
		path := '$f.bin_path/$bin'
		println(' - check exists: $path')
		if !os.exists(path) {
			return false
		}
	}
	if app.bins == [] {
		return false
	}
	return true
}

// copy binary related to app to the sandbox (~/hub3/bin) & register in metadata
pub fn (mut app AppInstance) bin_copy(path string, name_ string) ? {
	mut f := factory
	mut name := name_

	if name == '' {
		name = os.base(path)
	}

	path_dest := '$f.bin_path/$name'

	if !os.exists(f.bin_path) {
		return error('cannot find bin path to register in app: $app.name')
	}

	if os.exists(path_dest) {
		os.rm(path_dest)?
	}
	os.cp(path, path_dest)?

	app.bin_register(name)?
}

// register metadata
pub fn (mut app AppInstance) bin_register(name string) ? {
	mut f := factory
	path_dest := '$f.bin_path/$name'
	if !os.exists(path_dest) {
		return error('Cannot regster name:$name because does not exist in $path_dest')
	}
	if name !in app.bins {
		app.bins << name
	}
}
