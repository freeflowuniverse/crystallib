module zinit

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib

[heap]
pub struct Zinit {
pub mut:
	processes map[string]ZProcess
	path pathlib.Path
	pathcmds pathlib.Path
	pathtests pathlib.Path
}

pub fn new()! Zinit {
	mut obj := Zinit{
			path:pathlib.get_dir("/etc/zinit",true)!
			pathcmds:pathlib.get_dir("/etc/zinit/cmds",true)!
			pathtests:pathlib.get_dir("/etc/zinit/tests",true)!
		}

	cmd:="zinit list"
	r:=osal.execute_silent(cmd)!
	mut state:=""
	for line in r.split_into_lines(){
		if line.starts_with("---"){
			state="ok"
			continue
		}
		if state=="ok" && line.contains(":") {
			name:=line.split(":")[0].to_lower().trim_space()
			zp:=ZProcess{name:name,zinit:&obj}
			zp.load()!
			obj.processes[name]=zp
		}
	}
	return obj
}
