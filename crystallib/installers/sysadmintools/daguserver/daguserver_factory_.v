module daguserver

import freeflowuniverse.crystallib.core.base

__global (
	daguserver_global  map[string]&DaguServer
	daguserver_default string
)

/////////FACTORY

@[params]
pub struct ArgsGet {
pub mut:
	name string = 'default'
}

fn args_get(args_ ArgsGet) ArgsGet {
	mut args := args_
	if args.name == '' {
		args.name = daguserver_default
	}
	if args.name == '' {
		args.name = 'default'
	}
	return args
}

pub fn get(args_ ArgsGet) !&DaguServer {
	mut args := args_get(args_)
	if args.name !in daguserver_global {
		if !config_exists() {
			if default {
				config_save()!
			}
		}
		config_load()!
	}
	return daguserver_global[args.name] or { panic('bug') }
}

// switch instance to be used for daguserver
pub fn switch(name string) {
	daguserver_default = name
}

fn config_exists(args_ ArgsGet) bool {
	mut args := args_get(args_)
	mut context := base.context() or { panic('bug') }
	return context.hero_config_exists('daguserver', args.name)
}

fn config_load(args_ ArgsGet) ! {
	mut args := args_get(args_)
	mut context := base.context()!
	mut heroscript := context.hero_config_get('daguserver', args.name)!
	play(heroscript: heroscript)!
}

fn config_save(args_ ArgsGet) ! {
	mut args := args_get(args_)
	mut context := base.context()!
	context.hero_config_set('daguserver', args.name, heroscript_default)!
}

fn set(o DaguServer) ! {
	obj_init()!
	daguserver_global['default'] = &o
}
