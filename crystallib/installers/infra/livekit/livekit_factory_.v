
module livekit

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.core.playbook


import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.ui.console
import time

__global (
    livekit_global map[string]&LivekitServer
    livekit_default string
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
        args.name = livekit_default
    }
    if args.name == ""{
        args.name = "default"
    }
    return args
}

pub fn get(args_ ArgsGet) !&LivekitServer  {
    mut args := args_get(args_)
    if !(args.name in livekit_global) {
        if ! config_exists(){
            if default{
                config_save()!
            }
        }
        config_load()!
    }
    return livekit_global[args.name] or { 
            println(livekit_global)
            panic("bug in get from factory: ") 
        }
}




fn config_exists(args_ ArgsGet) bool {
    mut args := args_get(args_)
    mut context:=base.context() or { panic("bug") }
    return context.hero_config_exists("livekit",args.name)
}

fn config_load(args_ ArgsGet) ! {
    mut args := args_get(args_)
    mut context:=base.context()!
    mut heroscript := context.hero_config_get("livekit",args.name)!
    play(heroscript:heroscript)!
}

fn config_save(args_ ArgsGet) ! {
    mut args := args_get(args_)
    mut context:=base.context()!
    context.hero_config_set("livekit",args.name,heroscript_default()!)!
}


fn set(o LivekitServer)! {
    mut o2:=obj_init(o)!
    livekit_global["default"] = &o2
}


@[params]
pub struct PlayArgs {
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

pub fn play(args_ PlayArgs) ! {
    
    mut args:=args_


    if args.heroscript == "" {
        args.heroscript = heroscript_default()!
    }
    mut plbook := args.plbook or {
        playbook.new(text: args.heroscript)!
    }
    

    mut install_actions := plbook.find(filter: 'livekit.configure')!
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


//load from disk and make sure is properly intialized
pub fn (mut self LivekitServer) reload() ! {
    switch(self.name)
    self=obj_init(self)!
}


pub fn (mut self LivekitServer) start() ! {
    switch(self.name)
    if self.running()!{
        return
    }

    console.print_header('livekit start')

    configure()!

    start_pre()!

    mut sm := startupmanager.get()!

    for zprocess in startupcmd()!{
        sm.start(zprocess.name)!
    }

    start_post()!

    for _ in 0 .. 50 {
        if self.running()! {
            return
        }
        time.sleep(100 * time.millisecond)
    }
    return error('livekit did not install properly.')

}

pub fn (mut self LivekitServer) install_start(args RestartArgs) ! {
    switch(self.name)
    self.install(args)!
    self.start()!
}

pub fn (mut self LivekitServer) stop() ! {
    switch(self.name)
    stop_pre()!
    mut sm := startupmanager.get()!
    for zprocess in startupcmd()!{
        sm.stop(zprocess.name)!
    }
    stop_post()!
}

pub fn (mut self LivekitServer) restart() ! {
    switch(self.name)
    self.stop()!
    self.start()!
}

pub fn (mut self LivekitServer) running() !bool {
    switch(self.name)
    mut sm := startupmanager.get()!

    //walk over the generic processes, if not running return
    for zprocess in startupcmd()!{
        r:=sm.running(zprocess.name)!
        if r==false{
            return false
        }
    }
    return running()!
}

@[params]
pub struct InstallArgs{
pub mut:
    reset bool
}

pub fn (mut self LivekitServer) install(args InstallArgs) ! {
    switch(self.name)
    if args.reset || (!installed()!) {
        install()!
    }    
}



pub fn (mut self LivekitServer) destroy() ! {
    switch(self.name)

    self.stop()!
    destroy()!
}



//switch instance to be used for livekit
pub fn switch(name string) {
    livekit_default = name
}
