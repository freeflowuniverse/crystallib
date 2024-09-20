
module griddriver

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.core.playbook


import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.ui.console
import time

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


pub fn get(args_ ArgsGet) !&GridDriverInstaller  {
    return &GridDriverInstaller{}
}





////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////# LIVE CYCLE MANAGEMENT FOR INSTALLERS ///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////





@[params]
pub struct InstallArgs{
pub mut:
    reset bool
}

pub fn (mut self GridDriverInstaller) install(args InstallArgs) ! {
    switch(self.name)
    if args.reset || (!installed()!) {
        install()!
    }    
}


pub fn (mut self GridDriverInstaller) build() ! {
    switch(self.name)
    build()!
}

pub fn (mut self GridDriverInstaller) destroy() ! {
    switch(self.name)

    destroy()!
}



//switch instance to be used for griddriver
pub fn switch(name string) {
    griddriver_default = name
}
