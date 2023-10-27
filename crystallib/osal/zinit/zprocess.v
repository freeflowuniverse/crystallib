module zinit

import os
import freeflowuniverse.crystallib.osal
import yaml
import net.unix

pub struct ZProcess {
pub:
	name string
pub mut:
	cmd string
	test string
	status ZProcessStatus
	pid int
	after []string
	oneshot bool
	zinit &Zinit
}

pub enum ZProcessStatus{
	unknown
	init
	ok
	error
	blocked
	spawned
}

pub enum YamlState{
	start
	after
	env
}


pub fn (mut zp ZProcess) load()! {
	cmd:="zinit status ${zp.name}"
	r:=osal.execute_silent(cmd)!
	mut state:=""
	for line in r.split_into_lines(){
		if line.starts_with("pid"){
			zp.pid=line.split("pid:")[1].trim_space().int()
		}
		if line.starts_with("state"){
			st:=line.split("state:")[1].trim_space().to_lower()
			zp.status = match st {
				"spawned" {.spawned}
				 else{.unknown}
			}
		}
		// if line.starts_with("after"){
		// 	panic("implement")
		// }
	}
	if ! zp.zinit.path.file_exists(zp.name+".yaml"){
		return error("there should be a file ${zp.name}.yaml in /etc/zinit")
	}

	if zp.zinit.pathcmds.file_exists(zp.name){
		//means we can load the special cmd
		pathcmd:=zp.zinit.pathcmds.file_get(zp_name)!
		zp.cmd = pathcmd.read()!
	}
	if zp.zinit.pathtests.file_exists(zp.name){
		//means we can load the special cmd
		pathtest:=zp.zinit.path.cmds.file_get(zp_name)!
		zp.test = pathtest.read()!
	}

	pathyaml:=zp.zinit.pathcmds.file_get(zp.name+".yaml")!
	contentyaml:=pathyaml.read()!
	
	mut st:=YamlState{}
	for line in contentyaml.split_into_lines(){
		if line.starts_with("exec:") && zp.cmd.len==0 {
			zp.cmd=line.split("exec:")[1].trim("'\" ")
		}
		if line.starts_with("test:") && zp.cmd.len==0 {
			zp.test=line.split("test:")[1].trim("'\" ")
		}
		if line.starts_with("after:")  {	
			st=.after
			continue
		}
		if line.starts_with("env:")  {	
			st=.env
			continue
		}	
		if st==.after{
			if line.trim_space()==""{
				st=.start
			}else{
				line.trim_space().starts_with("-"){
					_,after:=line.split_once("-") or {panic("bug")}
					zp.after<< after.to_lower().trim_space()
				}
			}			
		}	
		if st==.env{
			if line.trim_space()==""{
				st=.start
			}else{
				line.contains("="){
					key,val:=line.split_once("=") or {panic("bug")}
					zp.env[key.trim_space()]=val.trim_space()
				}
			}	
		}	
	}	

}


[params]
pub struct ZProcessNewArgs {
pub mut:
	name string
	exec string
	test string
	after []string
	env []string
}
pub fn (mut args_ ZProcessNewArgs) new()! {
	mut args:=args_


}

pub fn (mut zp ZProcess) str()! {

	mut out:="""
exec: \"${exec}\"
test: \"${test}\"
signal:
  stop: SIGKILL
log: ring
"""
	if zp.oneshot{
		out+="oneshot: true\n"	
	}
	if zp.after.len>0{
		out+="after:\n"
		for val in zp.after{
			out+="  - ${val}\n"
		}
	}	
	if zp.env.len>0{
		out+="env:\n"
		for key,val in zp.env{
			out+="  ${key}:${val}\n"
		}
	}

}