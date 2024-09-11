
module tfgridclient

import freeflowuniverse.crystallib.core.base


__global (
    tfgridclient_global map[string]&TFGridClient
    tfgridclient_default string
)

/////////FACTORY

@[params]
pub struct ArgsGet{
pub mut:
    name string = "default"
}

fn args_get (args_ ArgsGet) ArgsGet {    
    mut args:=args_
    if args.name == ""{
        args.name = tfgridclient_default
    }
    if args.name == ""{
        args.name = "default"
    }    
    return args
}
 
pub fn get(args_ ArgsGet) !&TFGridClient  {
    mut args := args_get(args_)
    if !(args.name in tfgridclient_global) {
        if ! config_exists(){
            if default{
                config_save()!
            }
        }
        config_load()!
    }
    return tfgridclient_global[args.name] or { panic("bug") }
}

//switch instance to be used for tfgridclient
pub fn switch(name string) {
    tfgridclient_default = name
}


fn config_exists(args_ ArgsGet) bool {
    mut args := args_get(args_)
    mut context:=base.context() or { panic("bug") }
    return context.hero_config_exists("tfgridclient",args.name)
}

fn config_load(args_ ArgsGet) ! {
    mut args := args_get(args_)
    mut context:=base.context()!
    mut heroscript := context.hero_config_get("tfgridclient",args.name)!
    play(heroscript:heroscript)!
}

fn config_save(args_ ArgsGet) ! {
    mut args := args_get(args_)
    mut context:=base.context()!
    context.hero_config_set("tfgridclient",args.name,heroscript_default)!
}


fn set(o TFGridClient)! {
    obj_init()!
    tfgridclient_global["default"] = &o
}


