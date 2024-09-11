module rclone

import freeflowuniverse.crystallib.core.base

__global (
	rclone_global  map[string]&RClone
	rclone_default string
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
		args.name = rclone_default
	}
	if args.name == '' {
		args.name = 'default'
	}
	return args
}

pub fn get(args_ ArgsGet) !&RClone {
	mut args := args_get(args_)
	if args.name !in rclone_global {
		if !config_exists() {
			if default {
				config_save()!
			}
		}
		config_load()!
	}
	return rclone_global[args.name] or { panic('bug') }
}

// switch instance to be used for rclone
pub fn switch(name string) {
	rclone_default = name
}

fn config_exists(args_ ArgsGet) bool {
	mut args := args_get(args_)
	mut context := base.context() or { panic('bug') }
	return context.hero_config_exists('rclone', args.name)
}

fn config_load(args_ ArgsGet) ! {
	mut args := args_get(args_)
	mut context := base.context()!
	mut heroscript := context.hero_config_get('rclone', args.name)!
	play(heroscript: heroscript)!
}

fn config_save(args_ ArgsGet) ! {
	mut args := args_get(args_)
	mut context := base.context()!
	context.hero_config_set('rclone', args.name, heroscript_default)!
}

fn set(o RClone) ! {
	obj_init()!
	rclone_global['default'] = &o
}
