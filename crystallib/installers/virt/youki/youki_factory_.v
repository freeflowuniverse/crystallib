
module youki

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.core.playbook

import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.osal.zinit
import freeflowuniverse.crystallib.ui.console
import time

__global (
    youki_global map[string]&YoukiInstaller
    youki_default string
)

/////////FACTORY

@[params]
pub struct ArgsGet{
pub mut:
    name string = "default"
}

pub fn get(args_ ArgsGet) !&YoukiInstaller  {
    return &YoukiInstaller{}
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



@[params]
pub struct InstallArgs{
pub mut:
    reset bool
}

pub fn (mut self YoukiInstaller) install(args InstallArgs) ! {
    switch(self.name)
    if args.reset || (!installed()!) {
        install()!
    }    
}

pub fn (mut self YoukiInstaller) build() ! {
    switch(self.name)
    build()!
}

pub fn (mut self YoukiInstaller) destroy() ! {
    switch(self.name)
    destroy()!
}



//switch instance to be used for youki
pub fn switch(name string) {
    youki_default = name
}
