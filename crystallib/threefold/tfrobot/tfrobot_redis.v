module tfrobot

import json
// import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.clients.redisclient


pub fn config_get(configname string) !DeployConfig {
	mut redis := redisclient.core_get()!
	data:=redis.hget('tfrobot:${configname}', "config")!
	if data.len==0{
		return error("couldn't find tfrobot config with name:${configname}")
	}
	return json.decode(DeployConfig,data)!
	
}

pub fn vms_get(configname string) ![]VMOutput {
	mut vms:=[]VMOutput{}
	mut redis := redisclient.core_get()!
	for vmname in redis.hkeys('tfrobot:${configname}')!{
		if vmname=="config"{
			continue
		}
		vms<<vm_get(configname,vmname)!
	}
	return vms
}

pub fn vm_get(configname string,name string) !VMOutput {
	mut redis := redisclient.core_get()!
	data:=redis.hget('tfrobot:${configname}', name)!
	if data.len==0{
		return error("couldn't find tfrobot config with name:${name}")
	}
	return json.decode(VMOutput,data)!
	
}
