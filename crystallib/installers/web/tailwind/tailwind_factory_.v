
module tailwind

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.core.playbook


import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.ui.console
import time

__global (
    tailwind_global map[string]&Tailwind
    tailwind_default string
)

/////////FACTORY

@[params]
pub struct ArgsGet{
pub mut:
    name string = "default"
}


pub fn get(args_ ArgsGet) !&Tailwind  {
    return &Tailwind{}
}





////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////# LIVE CYCLE MANAGEMENT FOR INSTALLERS ///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////





@[params]
pub struct InstallArgs{
pub mut:
    reset bool
}

pub fn (mut self Tailwind) install(args InstallArgs) ! {
    switch(self.name)
    if args.reset || (!installed()!) {
        install()!
    }
}



pub fn (mut self Tailwind) destroy() ! {
    switch(self.name)

    destroy()!
}



//switch instance to be used for tailwind
pub fn switch(name string) {
    tailwind_default = name
}
