module systemd

// import os
import maps
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import os

@[heap]
pub struct SystemdProcess {
pub mut:
	name        string
	unit        string // as generated or used by systemd
	cmd         string
	pid         int
	env         map[string]string
	systemd     &Systemd           @[skip; str: skip]
	description string
	info        SystemdProcessInfo
}

pub fn (mut self SystemdProcess) servicefile_path() string {
	return '${self.systemd.path.path}/${self.name}.service'
}

pub fn (mut self SystemdProcess) write() ! {
	mut p := pathlib.get_file(path: self.servicefile_path(), create: true)!
	console.print_header(' systemd write service: ${p.path}')

	envs_lst := maps.to_array[string, string, string](self.env, fn (k string, v string) string {
		return 'Environment=${k}=${v}'
	})

	envs := envs_lst.join('\n')

	servicecontent := $tmpl('templates/service.yaml')
	p.write(servicecontent)!
}

pub fn (mut self SystemdProcess) start() ! {
	self.write()!
	cmd := '
	systemctl daemon-reload 
	systemctl enable ${self.name}
	systemctl start ${self.name}
	'
	// console.print_debug(cmd)
	_ = osal.execute_silent(cmd)!
	self.refresh()!
}

// get status from system
pub fn (mut self SystemdProcess) refresh() ! {
	self.systemd.load()!
	systemdobj2 := self.systemd.get(self.name)!
	self.info = systemdobj2.info
	self.description = systemdobj2.description
	self.name = systemdobj2.name
	self.unit = systemdobj2.unit
	self.cmd = systemdobj2.cmd
}

pub fn (mut self SystemdProcess) delete() ! {
	self.stop()!
	if os.exists(self.servicefile_path()) {
		os.rm(self.servicefile_path())!
	}
}

pub fn (mut self SystemdProcess) stop() ! {
	cmd := '
	systemctl daemon-reload
	systemctl disable ${self.name}
	systemctl stop ${self.name}
	'
	_ = osal.execute_silent(cmd)!
	self.systemd.load()!
}
