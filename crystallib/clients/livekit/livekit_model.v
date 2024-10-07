module livekit
import freeflowuniverse.crystallib.data.paramsparser
import os

pub const version = '0.0.0'
const singleton = false
const default = true


pub fn heroscript_default() !string {

    heroscript:="
    !!livekit.configure 
        name:'default'
        livekit_url:''
        livekit_api_key:''
        livekit_api_secret:''
        "

    return heroscript

}


pub struct LivekitClient {
pub mut:
    name string = 'default'
    livekit_url        string
    livekit_api_key    string
    livekit_api_secret string
}


fn cfg_play(p paramsparser.Params) ! {
    mut mycfg := LivekitClient{
        name: p.get_default('name', 'default')!
        livekit_url: p.get('livekit_url')!
        livekit_api_key: p.get('livekit_api_key')!
        livekit_api_secret: p.get('livekit_api_secret')!
    }
    set(mycfg)!
}     


fn obj_init(obj_ LivekitClient)!LivekitClient{
    //never call get here, only thing we can do here is work on object itself
    mut obj:=obj_
    return obj
}




