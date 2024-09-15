
module ${args.name}

import freeflowuniverse.crystallib.core.base


__global (
	${args.name}_global map[string]&${args.classname}
	${args.name}_default string
)

/////////FACTORY

^^[params]
pub struct ArgsGet{
pub mut:
    name string = "default"
}

fn args_get (args_ ArgsGet) ArgsGet {	
	mut args:=args_
	if args.name == ""{
		args.name = ${args.name}_default
	}
	if args.name == ""{
		args.name = "default"
	}	
	return args
}
 
pub fn get(args_ ArgsGet) !&${args.classname}  {
    mut args := args_get(args_)
	if !(args.name in ${args.name}_global) {
		if ! config_exists(){
			if default{
				config_save()!
			}
		}
		config_load()!
	}
	return ${args.name}_global[args.name] or { panic("bug") }
}

//switch instance to be used for ${args.name}
pub fn switch(name string) {
	${args.name}_default = name
}


fn config_exists(args_ ArgsGet) bool {
    mut args := args_get(args_)
	mut context:=base.context() or { panic("bug") }
	return context.hero_config_exists("${args.name}",args.name)
}

fn config_load(args_ ArgsGet) ! {
	mut args := args_get(args_)
	mut context:=base.context()!
	mut heroscript := context.hero_config_get("${args.name}",args.name)!
	play(heroscript:heroscript)!
}

fn config_save(args_ ArgsGet) ! {
	mut args := args_get(args_)
	mut context:=base.context()!
	context.hero_config_set("${args.name}",args.name,heroscript_default)!
}


fn set(o ${args.classname})! {
	obj_init()!
	${args.name}_global["default"] = &o
}


