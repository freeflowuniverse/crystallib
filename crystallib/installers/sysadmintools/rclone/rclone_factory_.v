
module rclone

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.core.playbook


import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.osal.zinit
import freeflowuniverse.crystallib.ui.console
import time

__global (
    rclone_global map[string]&RClone
    rclone_default string
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
        args.name = rclone_default
    }
    if args.name == ""{
        args.name = "default"
    }
    return args
}

pub fn get(args_ ArgsGet) !&RClone  {
    mut args := args_get(args_)
    if !(args.name in rclone_global) {
        if ! config_exists(){
            if default{
                config_save()!
            }
        }
        config_load()!
    }
    return rclone_global[args.name] or { 
            println(rclone_global)
            panic("bug in get from factory: ") 
        }
}




fn config_exists(args_ ArgsGet) bool {
    mut args := args_get(args_)
    mut context:=base.context() or { panic("bug") }
    return context.hero_config_exists("rclone",args.name)
}

fn config_load(args_ ArgsGet) ! {
    mut args := args_get(args_)
    mut context:=base.context()!
    mut heroscript := context.hero_config_get("rclone",args.name)!
    play(heroscript:heroscript)!
}

fn config_save(args_ ArgsGet) ! {
    mut args := args_get(args_)
    mut context:=base.context()!
    context.hero_config_set("rclone",args.name,heroscript_default()!)!
}


fn set(o RClone)! {
    mut o2:=obj_init(o)!
    rclone_global["default"] = &o2
}


@[params]
pub struct PlayArgs {
pub mut:
    name string = 'default'
    heroscript string  //if filled in then plbook will be made out of it
    plbook     ?playbook.PlayBook 
    reset      bool

    delete     bool
    configure  bool     //make sure there is at least one installed
}

pub fn play(args_ PlayArgs) ! {
    
    mut args:=args_


    if args.heroscript == "" {
        args.heroscript = heroscript_default()!
    }
    mut plbook := args.plbook or {
        playbook.new(text: args.heroscript)!
    }
    

    mut install_actions := plbook.find(filter: 'rclone.configure')!
    if install_actions.len > 0 {
        for install_action in install_actions {
            mut p := install_action.params
            mycfg:=cfg_play(p)!
            set(mycfg)!
        }
    }

}




////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////# LIVE CYCLE MANAGEMENT FOR INSTALLERS ///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

fn startupmanager_get(cat zinit.StartupManagerType) !startupmanager.StartupManager {
    // unknown
    // screen
    // zinit
    // tmux
    // systemd
    match cat{
        .zinit{
            console.print_debug("startupmanager: zinit")
            return startupmanager.get(cat:.zinit)!
        }
        .systemd{
            console.print_debug("startupmanager: systemd")
            return startupmanager.get(cat:.systemd)!
        }else{
            console.print_debug("startupmanager: auto")
            return startupmanager.get()!
        }
    }
}


//load from disk and make sure is properly intialized
pub fn (mut self RClone) reload() ! {
    switch(self.name)
    self=obj_init(self)!
}



@[params]
pub struct InstallArgs{
pub mut:
    reset bool
}

pub fn (mut self RClone) install(args InstallArgs) ! {
    switch(self.name)
    if args.reset || (!installed()!) {
        install()!
    }    
}



pub fn (mut self RClone) destroy() ! {
    switch(self.name)

    destroy()!
}



//switch instance to be used for rclone
pub fn switch(name string) {
    rclone_default = name
}
