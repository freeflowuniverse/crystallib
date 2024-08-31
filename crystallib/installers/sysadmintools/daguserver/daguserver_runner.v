module daguserver

import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.osal.zinit
import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.ui.console

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
        args.heroscript = heroscript_default
    }
    mut plbook := args.plbook or {
        playbook.new(text: args.heroscript)!
    }
    
    mut install_actions := plbook.find(filter: 'daguserver.configure')!
    if install_actions.len > 0 {
        for install_action in install_actions {
            mut p := install_action.params
            cfg_play(p)!
        }
    }

}

//load from disk and make sure is properly intialized
pub fn (mut self DaguCFG) reload() ! {
    switch(self.name)
    obj_init()!
}

pub fn (mut self DaguCFG) start() ! {
    switch(self.name)
    if self.running()!{
        return
    }

	console.print_header('dagu start')

	configure(cfg)!

    start_pre()!

	mut sm := startupmanager.get()!

    for zprocess in startupcmd(){
    	sm.start_process(zprocess)!
    }

    start_post()!

	for _ in 0 .. 50 {
		if self.running()! {
			return
		}
		time.sleep(100 * time.millisecond)
	}
	return error('dagu did not install properly.')

}

pub fn (mut self DaguCFG) stop() ! {
    switch(self.name)
    stop_pre()!
    for zprocess in startupcmd(){
    	sm.stop_process(zprocess)!
    }
    stop_post()!
}

pub fn (mut self DaguCFG) restart() ! {
    switch(self.name)    
    self.stop()!
    self.start()!
}

pub fn (mut self DaguCFG) destroy() ! {
    switch(self.name)    
    self.stop()!
    destroy()!
}

pub fn (mut self DaguCFG) running() ! {
    switch(self.name)    

	mut sm := startupmanager.get()!

    //walk over the generic processes, if not running return
    for zprocess in startupcmd(){
    	r:=sm.process_running(zprocess)!
        if r==false{
            return false
        }
    }

    return running()!

}

