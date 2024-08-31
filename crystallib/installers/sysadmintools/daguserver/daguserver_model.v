module daguserver
import freeflowuniverse.crystallib.data.paramsparser

pub const version = '1.14.3'
const singleton = true
const heroscript_default = "

!!daguserver.configure
    homedir: '{HOME}/hero/var/dagu'
    configpath: '{HOME}/.config/dagu/admin.yaml'
    username: 'admin'
    password: 'secretpassword'
    secret: ''
    title: 'My Hero DAG'
    host: 'localhost'
    port: 8888

!!daguserver.start
!!daguserver.stop
!!daguserver.restart
!!daguserver.delete
!!daguserver.check

"

pub struct DaguCFG {
pub mut:
    name string = 'default'
	homedir    string
	configpath string
	username   string = 'admin'
	password   string @[secret]
	secret     string @[secret]
	title      string = 'My Hero DAG'
	host       string = 'localhost' // server host (default is localhost), all would be '::'
	port       int    = 8888
}

pub fn cfg_play(p paramsparser.Params) ! {

    mut mycfg := DaguCFG{
        homedir: p.get_default('homedir', '{HOME}/hero/var/dagu')!
        configpath: p.get_default('configpath', '{HOME}/hero/var/dagu/admin.yaml')!
        username: p.get_default('username', 'admin')!
        password: p.get_default('password', '')!
        secret: p.get_default('secret', '')!
        title: p.get_default('title', 'HERO DAG')!
        host: p.get_default('host', 'localhost')!
        port: p.get_int_default('port', 8888)!
    }

    if mycfg.password == '' && mycfg.secret == '' {
        return error('password or secret needs to be filled in for dagu')
    }

    set(cfg:mycfg)!
}

pub fn (mut self DaguCFG) init() ! {
}

pub fn (mut self DaguCFG) start() ! {
    switch(self.name)
    start()!
}

pub fn (mut self DaguCFG) stop() ! {
    switch(self.name)    
    stop()!
}

pub fn (mut self DaguCFG) restart() ! {
    switch(self.name)    
    stop()!
    start()!
}

pub fn (mut self DaguCFG) destroy() ! {
    switch(self.name)    
    destroy()!
}

pub fn (mut self DaguCFG) init() ! {
    switch(self.name)    
    destroy()!
}

pub fn (mut self DaguCFG) init() ! {
    switch(self.name)    
    destroy()!
}