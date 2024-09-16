module griddriver
import freeflowuniverse.crystallib.data.paramsparser

pub const version = '1.14.3'
const singleton = true
const default = true

//TODO: THIS IS EXAMPLE CODE AND NEEDS TO BE CHANGED IN LINE TO STRUCT BELOW, IS STRUCTURED AS HEROSCRIPT
pub fn heroscript_default() string {

    heroscript:="
        "


    return heroscript

}

//THIS THE THE SOURCE OF THE INFORMATION OF THIS FILE, HERE WE HAVE THE CONFIG OBJECT CONFIGURED AND MODELLED


pub struct GridDriverInstaller {
pub mut:
    name string = 'default'
}

fn cfg_play(p paramsparser.Params) ! {
    mut mycfg := GridDriverInstaller{
    }
    set(mycfg)!
}


fn obj_init(obj_ GridDriverInstaller)!GridDriverInstaller{
    //never call get here, only thing we can do here is work on object itself
    mut obj:=obj_
    return obj
}




