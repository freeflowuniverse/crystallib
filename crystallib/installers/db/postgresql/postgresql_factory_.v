
module postgresql

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.core.playbook

import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.osal.zinit
import freeflowuniverse.crystallib.ui.console
import time

__global (
    postgresql_global map[string]&Postgresql
    postgresql_default string
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
        args.name = postgresql_default
    }
    if args.name == ""{
        args.name = "default"
    }
    return args
}

pub fn get(args_ ArgsGet) !&Postgresql  {
    mut args := args_get(args_)
    if !(args.name in postgresql_global) {
        if ! config_exists(){
            if default{
                config_save()!
            }
        }
        config_load()!
    }
    return postgresql_global[args.name] or { 
            println(postgresql_global)
            panic("bug in get from factory: ") 
        }
}



fn config_exists(args_ ArgsGet) bool {
    mut args := args_get(args_)
    mut context:=base.context() or { panic("bug") }
    return context.hero_config_exists("postgresql",args.name)
}

fn config_load(args_ ArgsGet) ! {
    mut args := args_get(args_)
    mut context:=base.context()!
    mut heroscript := context.hero_config_get("postgresql",args.name)!
    play(heroscript:heroscript)!
}

fn config_save(args_ ArgsGet) ! {
    mut args := args_get(args_)
    mut context:=base.context()!
    context.hero_config_set("postgresql",args.name,heroscript_default()!)!
}


fn set(o Postgresql)! {
    mut o2:=obj_init(o)!
    postgresql_global["default"] = &o2
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
    
    mut install_actions := plbook.find(filter: 'postgresql.configure')!
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
pub fn (mut self Postgresql) reload() ! {
    switch(self.name)
    self=obj_init(self)!
}

pub fn (mut self Postgresql) start() ! {
    switch(self.name)
    if self.running()!{
        return
    }

    console.print_header('postgresql start')

    if ! installed()!{
        install()!
    }

    configure()!

    start_pre()!

    for zprocess in startupcmd()!{
        mut sm:=startupmanager_get(zprocess.startuptype)!

        console.print_debug('starting postgresql with ${zprocess.startuptype}...')

        sm.new(zprocess)!

        sm.start(zprocess.name)!
    }

    start_post()!

    for _ in 0 .. 50 {
        if self.running()! {
            return
        }
        time.sleep(100 * time.millisecond)
    }
    return error('postgresql did not install properly.')

}

pub fn (mut self Postgresql) install_start(args InstallArgs) ! {
    switch(self.name)
    self.install(args)!
    self.start()!
}

pub fn (mut self Postgresql) stop() ! {
    switch(self.name)
    stop_pre()!
    for zprocess in startupcmd()!{
        mut sm:=startupmanager_get(zprocess.startuptype)!
        sm.stop(zprocess.name)!
    }
    stop_post()!
}

pub fn (mut self Postgresql) restart() ! {
    switch(self.name)
    self.stop()!
    self.start()!
}

pub fn (mut self Postgresql) running() !bool {
    switch(self.name)

    //walk over the generic processes, if not running return
    for zprocess in startupcmd()!{
        mut sm:=startupmanager_get(zprocess.startuptype)!
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

pub fn (mut self Postgresql) install(args InstallArgs) ! {
    switch(self.name)
    if args.reset || (!installed()!) {
        install()!
    }    
}


pub fn (mut self Postgresql) destroy() ! {
    switch(self.name)
    self.stop() or {
        println('faild to stop: ${err}')
    }
    
    for zprocess in startupcmd()!{
        mut sm:= startupmanager_get(zprocess.startuptype)!
        sm.delete(zprocess.name)!
    }
}



//switch instance to be used for postgresql
pub fn switch(name string) {
    postgresql_default = name
}
