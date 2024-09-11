module caddy
import freeflowuniverse.crystallib.data.paramsparser


pub const version = '1.14.3'
const singleton = true
const default = true
//TODO: THIS IS EXAMPLE CODE AND NEEDS TO BE CHANGED IN LINE TO STRUCT BELOW, IS STRUCTURED AS HEROSCRIPT
const heroscript_default = "
!!caddy.configure
    homedir: '{HOME}/hero/var/caddy'
    configpath: '{HOME}/.config/caddy/admin.yaml'
    username: 'admin'
    password: 'secretpassword'
    secret: ''
    title: 'My Hero DAG'
    host: 'localhost'
    port: 8888


// !!caddy.start
// !!caddy.stop
// !!caddy.restart
// !!caddy.delete
// !!caddy.check
"

//THIS THE THE SOURCE OF THE INFORMATION OF THIS FILE, HERE WE HAVE THE CONFIG OBJECT CONFIGURED AND MODELLED
pub struct CaddyServer {
pub mut:
    name string = 'default'
    homedir    string
    configpath string
    username   string
    password   string @[secret]
    secret     string @[secret]
    title      string
    host       string
    port       int
}

fn cfg_play(p paramsparser.Params) ! {
    //THIS IS EXAMPLE CODE AND NEEDS TO BE CHANGED IN LINE WITH struct above
    mut mycfg := CaddyServer{
        homedir: p.get_default('homedir', '{HOME}/hero/var/caddy')!
        configpath: p.get_default('configpath', '{HOME}/hero/var/caddy/admin.yaml')!
        username: p.get_default('username', 'admin')!
        password: p.get_default('password', '')!
        secret: p.get_default('secret', '')!
        title: p.get_default('title', 'HERO DAG')!
        host: p.get_default('host', 'localhost')!
        port: p.get_int_default('port', 8888)!
    }

    if mycfg.password == '' && mycfg.secret == '' {
        return error('password or secret needs to be filled in for caddy')
    }

    set(mycfg)!
}
