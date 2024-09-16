
module griddriver

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.core.playbook



__global (
    griddriver_global map[string]&GridDriverInstaller
    griddriver_default string
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
        args.name = griddriver_default
    }
    if args.name == ""{
        args.name = "default"
    }
    return args
}

pub fn get(args_ ArgsGet) !&GridDriverInstaller  {
    mut args := args_get(args_)
    if !(args.name in griddriver_global) {
        if ! config_exists(){
            if default{
                config_save()!
            }
        }
        config_load()!
    }
    return griddriver_global[args.name] or { panic("bug") }
}

//switch instance to be used for griddriver
pub fn switch(name string) {
    griddriver_default = name
}


fn config_exists(args_ ArgsGet) bool {
    mut args := args_get(args_)
    mut context:=base.context() or { panic("bug") }
    return context.hero_config_exists("griddriver",args.name)
}

fn config_load(args_ ArgsGet) ! {
    mut args := args_get(args_)
    mut context:=base.context()!
    mut heroscript := context.hero_config_get("griddriver",args.name)!
    play(heroscript:heroscript)!
}

fn config_save(args_ ArgsGet) ! {
    mut args := args_get(args_)
    mut context:=base.context()!
    context.hero_config_set("griddriver",args.name,heroscript_default())!
}


fn set(o GridDriverInstaller)! {
    mut o2:=obj_init(o)!
    griddriver_global["default"] = &o2
}


@[params]
pub struct InstallPlayArgs {
pub mut:
    name string = 'default'
    heroscript string  //if filled in then plbook will be made out of it
    plbook     ?playbook.PlayBook 
    reset      bool
    start      bool
    stop       bool
    restart    bool
    delete     bool
    configure  bool     //make sure there is at least one installed

}

pub fn play(args_ InstallPlayArgs) ! {
    
    mut args:=args_

    if args.heroscript == "" {
        args.heroscript = heroscript_default()
    }
    mut plbook := args.plbook or {
        playbook.new(text: args.heroscript)!
    }
    
    mut install_actions := plbook.find(filter: 'griddriver.configure')!
    if install_actions.len > 0 {
        for install_action in install_actions {
            mut p := install_action.params
            cfg_play(p)!
        }
    }

}



////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////# LIVE CYCLE MANAGEMENT FOR INSTALLERS ///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////



@[params]
pub struct RestartArgs{
pub mut:
    reset bool
}

pub fn (mut self GridDriverInstaller) install(args RestartArgs) ! {
    switch(self.name)
    if args.reset || (!installed()!) {
        install()!
    }    
}

pub fn (mut self GridDriverInstaller) destroy() ! {
    switch(self.name)

    destroy()!
}

