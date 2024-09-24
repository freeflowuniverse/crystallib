module daguserver
import freeflowuniverse.crystallib.data.paramsparser
import os

pub const version = '1.14.3'
const singleton = true
const default = true


pub fn heroscript_default() !string {

    heroscript:="
    !!daguserver.configure 
        name:'daguserver'
        homedir: '{HOME}/hero/var/daguserver'
        configpath: '{HOME}/.config/daguserver/admin.yaml'
        username: 'admin'
        password: 'secretpassword'
        secret: ''
        title: 'My Hero DAG'
        host: 'localhost'
        port: 8888

        "

    return heroscript

}


pub struct DaguInstaller {
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

fn cfg_play(p paramsparser.Params) !DaguInstaller {
    //THIS IS EXAMPLE CODE AND NEEDS TO BE CHANGED IN LINE WITH struct above
    mut mycfg := DaguInstaller{
        name: p.get_default('name', 'default')!
        homedir: p.get_default('homedir', '{HOME}/hero/var/daguserver')!
        configpath: p.get_default('configpath', '{HOME}/hero/var/daguserver/admin.yaml')!
        username: p.get_default('username', 'admin')!
        password: p.get_default('password', '')!
        secret: p.get_default('secret', '')!
        title: p.get_default('title', 'HERO DAG')!
        host: p.get_default('host', 'localhost')!
        port: p.get_int_default('port', 8888)!
    }

    if mycfg.password == '' && mycfg.secret == '' {
        return error('password or secret needs to be filled in for daguserver')
    }
    return mycfg
}


fn obj_init(obj_ DaguInstaller)!DaguInstaller{
    //never call get here, only thing we can do here is work on object itself
    mut obj:=obj_
    return obj
}


