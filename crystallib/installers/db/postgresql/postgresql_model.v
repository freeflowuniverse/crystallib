module postgresql
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.pathlib
import os

pub const version = '0.0.0'
const singleton = true
const default = true

pub fn heroscript_default() !string {
    heroscript:="
    !!postgresql.configure 
        name:'default'
        passwd:'mysecret'
        path:''
        "
    return heroscript

}

pub struct Postgresql {
pub mut:
    name string = 'default'
	path   string
	passwd string
}

fn cfg_play(p paramsparser.Params) !Postgresql {
    mut mycfg := Postgresql{
        name: p.get_default('name', 'default')!
        passwd: p.get('passwd')!
        path: p.get_default('path','')!
    }
    return mycfg
}


fn obj_init(obj_ Postgresql)!Postgresql{
    mut obj:=obj_
	if obj.path == '' {
		if osal.is_linux() {
			obj.path = '/data/postgresql/${obj.name}'
		} else {
			obj.path = '${os.home_dir()}/hero/var/postgresql/${obj.name}'
		}
	}    
    return obj
}

//called before start if done
fn configure() ! {
    mut cfg := get()!

    mut mypath:=pathlib.get_dir(path:cfg.path,create:false)!

	t1 := $tmpl('templates/compose.yaml')
	mut p1 := mypath.file_get_new('compose.yaml')!
	p1.write(t1)!

	// t2 := $tmpl('templates/pg_hba.conf')
	// mut p2 := server.path_config.file_get_new('pg_hba.conf')!
	// p2.write(t2)!

	// mut t3 := $tmpl('templates/postgresql.conf')
	// t3 = t3.replace('@@', '$') // to fix templating issues
	// mut p3 := server.path_config.file_get_new('postgresql.conf')!
	// p3.write(t3)!

}


