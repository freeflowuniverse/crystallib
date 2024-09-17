module griddriver

import freeflowuniverse.crystallib.data.paramsparser

pub const version = '1.14.3'
const singleton = true
const default = true

pub struct GridDriverInstaller {
pub mut:
	name string = 'default'
}

fn cfg_play(p paramsparser.Params) ! {
	mut mycfg := GridDriverInstaller{}
}

fn obj_init(obj_ GridDriverInstaller) !GridDriverInstaller {
	// never call get here, only thing we can do here is work on object itself
	mut obj := obj_
	return obj
}
