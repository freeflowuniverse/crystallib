
module zinit

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.core.playbook

import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.osal.zinit
import freeflowuniverse.crystallib.ui.console
import time

__global (
    zinit_global map[string]&Zinit
    zinit_default string
)

/////////FACTORY

@[params]
pub struct ArgsGet{
pub mut:
    name string = "default"
}

pub fn get(args_ ArgsGet) !&Zinit  {
    return &Zinit{}
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


pub fn (mut self Zinit) start() ! {
    switch(self.name)
    if self.running()!{
        return
    }

    console.print_header('zinit start')

    println("0000")

    if ! installed()!{
        install()!
    }

    println("003333")

    configure()!

    println("000222")

    start_pre()!

    for zprocess in startupcmd()!{
        mut sm:= startupmanager_get(zprocess.startuptype)!

        console.print_debug('starting zinit with ${zprocess.startuptype}...')

        sm.new(zprocess)!

        println("11111")

        // sm.start(zprocess.name)!
    }

    println("222222")

    start_post()!

    for _ in 0 .. 50 {
        println("4444")
        if self.running()! {
            return
        }
        time.sleep(100 * time.millisecond)
    }
    return error('zinit did not install properly.')

}

pub fn (mut self Zinit) install_start(args InstallArgs) ! {
    switch(self.name)
    self.install(args)!
    self.start()!
}

pub fn (mut self Zinit) stop() ! {
    switch(self.name)
    stop_pre()!
    for zprocess in startupcmd()!{
        mut sm:=startupmanager_get(zprocess.startuptype)!
        sm.stop(zprocess.name)!
    }
    stop_post()!
}

pub fn (mut self Zinit) restart() ! {
    switch(self.name)
    self.stop()!
    self.start()!
}

pub fn (mut self Zinit) running() !bool {
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

pub fn (mut self Zinit) install(args InstallArgs) ! {
    switch(self.name)
    if args.reset || (!installed()!) {
        install()!
    }    
}

pub fn (mut self Zinit) build() ! {
    switch(self.name)
    build()!
}

pub fn (mut self Zinit) destroy() ! {
    switch(self.name)
    self.stop()!
    destroy()!
}



//switch instance to be used for zinit
pub fn switch(name string) {
    zinit_default = name
}
