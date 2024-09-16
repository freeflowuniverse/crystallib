
module caddy

import freeflowuniverse.crystallib.core.base


__global (
    caddy_global map[string]&CaddyServer
    caddy_default string
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
        args.name = caddy_default
    }
    if args.name == ""{
        args.name = "default"
    }    
    return args
}
 
pub fn get(args_ ArgsGet) !&CaddyServer  {
    mut args := args_get(args_)
    if !(args.name in caddy_global) {
        if ! config_exists(){
            if default{
                config_save()!
            }
        }
        config_load()!
    }
    return caddy_global[args.name] or { panic("bug") }
}

//switch instance to be used for caddy
pub fn switch(name string) {
    caddy_default = name
}


fn config_exists(args_ ArgsGet) bool {
    mut args := args_get(args_)
    mut context:=base.context() or { panic("bug") }
    return context.hero_config_exists("caddy",args.name)
}

// fn config_load(args_ ArgsGet) ! {
//     mut args := args_get(args_)
//     mut context:=base.context()!
//     mut heroscript := context.hero_config_get("caddy",args.name)!
//     play(heroscript:heroscript)!
// }

fn config_save(args_ ArgsGet) ! {
    mut args := args_get(args_)
    mut context:=base.context()!
    context.hero_config_set("caddy",args.name,heroscript_default)!
}


fn set(o CaddyServer)! {
    obj_init()!
    caddy_global["default"] = &o
}


