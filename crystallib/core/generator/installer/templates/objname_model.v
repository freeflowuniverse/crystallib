module ${args.name}
import freeflowuniverse.crystallib.data.paramsparser


pub const version = '1.14.3'
const singleton = ${args.singleton}
const default = ${args.default}
//TODO: THIS IS EXAMPLE CODE AND NEEDS TO BE CHANGED IN LINE TO STRUCT BELOW, IS STRUCTURED AS HEROSCRIPT
const heroscript_default = "
!!${args.name}.configure
    homedir: '{HOME}/hero/var/${args.name}'
    configpath: '{HOME}/.config/${args.name}/admin.yaml'
    username: 'admin'
    password: 'secretpassword'
    secret: ''
    title: 'My Hero DAG'
    host: 'localhost'
    port: 8888

@if args.startupmanager
// !!${args.name}.start
// !!${args.name}.stop
// !!${args.name}.restart
// !!${args.name}.delete
// !!${args.name}.check
@end
"

//THIS THE THE SOURCE OF THE INFORMATION OF THIS FILE, HERE WE HAVE THE CONFIG OBJECT CONFIGURED AND MODELLED
pub struct ${args.classname} {
pub mut:
    name string = 'default'
	homedir    string
	configpath string
	username   string
	password   string @@[secret]
	secret     string @@[secret]
	title      string
	host       string
	port       int
}

fn cfg_play(p paramsparser.Params) ! {
    //THIS IS EXAMPLE CODE AND NEEDS TO BE CHANGED IN LINE WITH struct above
    mut mycfg := ${args.classname}{
        homedir: p.get_default('homedir', '{HOME}/hero/var/${args.name}')!
        configpath: p.get_default('configpath', '{HOME}/hero/var/${args.name}/admin.yaml')!
        username: p.get_default('username', 'admin')!
        password: p.get_default('password', '')!
        secret: p.get_default('secret', '')!
        title: p.get_default('title', 'HERO DAG')!
        host: p.get_default('host', 'localhost')!
        port: p.get_int_default('port', 8888)!
    }

    if mycfg.password == '' && mycfg.secret == '' {
        return error('password or secret needs to be filled in for ${args.name}')
    }

    set(mycfg)!
}
