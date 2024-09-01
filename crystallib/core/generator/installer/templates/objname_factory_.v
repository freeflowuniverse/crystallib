
module ${args.name}

import freeflowuniverse.crystallib.core.base


__global (
	${args.name}_global map[string]&${args.classname}
	${args.name}_default string
)

/////////FACTORY

@if args.default
pub fn get() !&${args.classname}  {
	name := "default"
@else
pub fn get(name string) !&${args.classname} 
@end
	if !(name in ${args.name}_global) {
		if ! config_exists(){
			if default{
				config_save()!
			}
		}
		config_load()!
	}
	return ${args.name}_global[name] or { panic("bug") }
}


@if args.default
//switch instance to be used for ${args.name}
pub fn switch(name string) {
	${args.name}_default = name
}
@end


@if args.default
fn config_exists() bool {
	name := "default"
@else
fn config_exists(name string) bool {
@end
	mut context:=base.context() or { panic("bug") }
	return context.hero_config_exists("${args.name}",name)
}

@if args.default
fn config_load() bool {
	name := "default"
@else
fn config_load(name string) bool {
@end
	mut context:=base.context()!
	mut heroscript := context.hero_config_get("${args.name}",name)!
	play(heroscript:heroscript)!
}

@if args.default
fn config_save() bool {
	name := "default"
@else
fn config_save(name string) bool {
@end
	mut context:=base.context()!
	context.hero_config_set("${args.name}",name,heroscript_default)!
}


fn set(o ${args.classname})! {
	obj_init()!
	${args.name}_global["default"] = &o
}


