module systemd

// import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console

@[heap]
pub struct SystemdProcess {
pub mut:
	name        string
	unit        string // as generated or used by systemd
	cmd         string
	pid         int
	env         map[string]string
	systemdobj  &Systemd           @[skip; str: skip]
	description string
	info        SystemdProcessInfo
}

pub fn (mut self SystemdProcess) start() ! {
	if !(self.name.ends_with('.service')) {
		return error('service name needs to end with .server.\n${self}')
	}
	mut p := pathlib.get_file(path: '${self.systemdobj.path.path}/${self.name}', create: true)!
	console.print_header(' systemd write service: ${p.path}')
	servicecontent := $tmpl('templates/service.yaml')
	p.write(servicecontent)!
	cmd := '
	systemctl daemon-reload 
	systemctl enable ${self.name}
	systemctl start ${self.name}
	'
	console.print_debug(cmd)
	_ = osal.execute_silent(cmd)!
	self.refresh()!
}

// get status from system
pub fn (mut self SystemdProcess) refresh() ! {
	self.systemdobj.load()!
	systemdobj2 := self.systemdobj.get(self.name)!
	self.info = systemdobj2.info
	self.description = systemdobj2.description
	self.name = systemdobj2.name
	self.unit = systemdobj2.unit
	self.cmd = systemdobj2.cmd
}

pub fn (mut self SystemdProcess) remove() ! {
	_ = pathlib.get_file(
		path: '${self.systemdobj.path.path}/${self.name}.service'
		create: true
	)!
	cmd := '
	systemctl daemon-reload
	systemctl disable ${self.name}
	systemctl stop ${self.name}
	'
	_ = osal.execute_silent(cmd)!
	self.systemdobj.load()!
}

// pub fn (self SystemdProcess) cmd() string {
// 	p := '/etc/systemd/cmd/${self.name}.sh'
// 	if os.exists(p) {
// 		return "bash -c \"${p}\""
// 	} else {
// 		if self.cmd.contains('\n') {
// 			panic('cmd cannot have \\n and not have cmd file on disk on ${p}')
// 		}
// 	}
// 	return '${self.cmd}'
// }

// pub fn (mut self SystemdProcess) load() ! {
// 	//get info from systemd
// }

// pub fn (self SystemdProcess) str() string {
// 	mut out := "
// IPROCESS:
// exec: \"${self.cmd()}\"
// "
// 	if self.env.len > 0 {
// 		out += 'env:\n'
// 		for key, val in self.env {
// 			out += '  ${key}:${val}\n'
// 		}
// 	}
// 	return out
// }
