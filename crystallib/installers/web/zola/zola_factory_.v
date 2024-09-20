
module zola

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.core.playbook


import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.ui.console
import time

__global (
    zola_global map[string]&ZolaInstaller
    zola_default string
)

/////////FACTORY

@[params]
pub struct ArgsGet{
pub mut:
    name string = "default"
}


pub fn get(args_ ArgsGet) !&ZolaInstaller  {
    return &ZolaInstaller{}
}





////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////# LIVE CYCLE MANAGEMENT FOR INSTALLERS ///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////





@[params]
pub struct InstallArgs{
pub mut:
    reset bool
}

pub fn (mut self ZolaInstaller) install(args InstallArgs) ! {
    switch(self.name)
    if args.reset || (!installed()!) {
        install()!
    }
}



pub fn (mut self ZolaInstaller) destroy() ! {
    switch(self.name)

    destroy()!
}



//switch instance to be used for zola
pub fn switch(name string) {
    zola_default = name
}
