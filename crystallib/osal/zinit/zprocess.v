module zinit

import os
import freeflowuniverse.crystallib.osal


pub struct ZProcess {
pub:
	name string
pub mut:
	cmd string
	test string
	status ZProcessStatus
	pid int
	after []string
	env map[string]string
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

pub fn (zp ZProcess) cmd() string {
	p:="/etc/zinit/cmd/${zp.name}.sh"
	if os.exists(p){
		return "bash -c \"${p}\""
	}else{
		if zp.cmd.contains("\n"){
			panic("cmd cannot have \\n and not have cmd file on disk on ${p}")
		}
	}
	return "${zp.cmd}"
}

pub fn (zp ZProcess) cmdtest() string {
	p:="/etc/zinit/tests/${zp.name}.sh"
	if os.exists(p){
		return "bash -c \"${p}\""
	}else{
		if zp.test.contains("\n"){
			panic("cmd cannot have \\n and not have cmd file on disk on ${p}")
		}
	}
	return "${zp.test}"
}



pub fn (mut zp ZProcess) load()! {
	cmd:="zinit status ${zp.name}"
	r:=osal.execute_silent(cmd)!
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
		mut pathcmd:=zp.zinit.pathcmds.file_get(zp.name)!
		zp.cmd = pathcmd.read()!
	}
	if zp.zinit.pathtests.file_exists(zp.name){
		//means we can load the special cmd
		mut pathtest:=zp.zinit.path.file_get(zp.name)!
		zp.test = pathtest.read()!
	}

	mut pathyaml:=zp.zinit.pathcmds.file_get(zp.name+".yaml")!
	contentyaml:=pathyaml.read()!
	
	mut st:=""
	for line in contentyaml.split_into_lines(){
		if line.starts_with("exec:") && zp.cmd.len==0 {
			zp.cmd=line.split("exec:")[1].trim("'\" ")
		}
		if line.starts_with("test:") && zp.cmd.len==0 {
			zp.test=line.split("test:")[1].trim("'\" ")
		}
		if line.starts_with("after:")  {	
			st="after"
			continue
		}
		if line.starts_with("env:")  {	
			st="env"
			continue
		}	
		if st=="after"{
			if line.trim_space()==""{
				st="start"
			}else{
				line.trim_space().starts_with("-"){
					_,after:=line.split_once("-") or {panic("bug")}
					zp.after<< after.to_lower().trim_space()
				}
			}			
		}	
		if st=="env"{
			if line.trim_space()==""{
				st="start"
			}else{
				line.contains("="){
					key,val:=line.split_once("=") or {panic("bug")}
					zp.env[key.trim_space()]=val.trim_space()
				}
			}	
		}	
	}	

}



pub fn (zp ZProcess) str() string {

	mut out:="
exec: \"${zp.cmd()}\"
test: \"${zp.cmdtest()}\"
signal:
  stop: SIGKILL
log: ring
"
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
	return out
}