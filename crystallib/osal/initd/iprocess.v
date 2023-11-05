module initd

// import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib

pub struct IProcess {
pub mut:
	name string
	cmd     string
	status  IProcessStatus
	pid     int
	env     map[string]string
	initd   &Initd [skip; str: skip]
	description string
}

pub enum IProcessStatus {
	unknown
	running
	exited
	deleted
}

// pub fn (zp IProcess) cmd() string {
// 	p := '/etc/initd/cmd/${zp.name}.sh'
// 	if os.exists(p) {
// 		return "bash -c \"${p}\""
// 	} else {
// 		if zp.cmd.contains('\n') {
// 			panic('cmd cannot have \\n and not have cmd file on disk on ${p}')
// 		}
// 	}
// 	return '${zp.cmd}'
// }

// pub fn (mut zp IProcess) load() ! {
// 	//get info from initd
// }

// pub fn (zp IProcess) str() string {
// 	mut out := "
// IPROCESS:
// exec: \"${zp.cmd()}\"
// "
// 	if zp.env.len > 0 {
// 		out += 'env:\n'
// 		for key, val in zp.env {
// 			out += '  ${key}:${val}\n'
// 		}
// 	}
// 	return out
// }

pub fn (mut zp IProcess) start() ! {

    mut p:=pathlib.get_file(path:"${zp.initd.path.path}/${zp.name}.service",create:true)!

	servicecontent:=$tmpl('templates/service.yaml')
	p.write(servicecontent)!
	cmd:="
	systemctl daemon-reload 
	systemctl enable ${zp.name}
	systemctl start ${zp.name}
	"	
	r := osal.execute_silent(cmd)!
	zp.refresh()!

}

//get status from system
pub fn (mut zp IProcess) refresh() ! {
	zp.initd.load()!	
	initdobj2:=zp.initd.get(zp.name)!
	zp.status = initdobj2.status
}

pub fn (mut zp IProcess) remove() ! {

    mut p:=pathlib.get_file(path:"${zp.initd.path.path}/${zp.name}.service",create:true)!
	cmd:="
	systemctl daemon-reload
	systemctl disable ${zp.name}
	systemctl stop ${zp.name}
	"	
	r := osal.execute_silent(cmd)!
	p.delete()!
	zp.status=.deleted

}
