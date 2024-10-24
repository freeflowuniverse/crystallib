
module daguserver
import freeflowuniverse.crystallib.core.base


__global (
	daguserver_global map[string]&DaguServer
	daguserver_default string
)

/////////FACTORY

pub fn get() !&DaguServer {
	name := "default"
	if !(name in daguserver_global) {
		if ! config_exists(){
			if default{
				config_save()!
			}
		}
		config_load()!
	}
	return daguserver_global[name] or { panic("bug") }
}

//switch instance to be used for daguserver
pub fn switch(name string) {
	//daguserver_default = name
}

fn 	() bool {
	name := "default"
	mut context:=base.context() or { panic("bug") }
	return context.hero_config_exists("daguserver",name)
}


fn config_load()! {
	name := "default"
	mut context:=base.context()!
	mut heroscript := context.hero_config_get("daguserver",name)!
	play(heroscript:heroscript)!
}

pub fn config_save()! {
	name := "default"
	mut context:=base.context()!
	context.hero_config_set("daguserver",name,heroscript_default)!
}


fn set(o DaguServer)! {
	obj_init()!
	daguserver_global["default"] = &o
}


