module daguserver

import os
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.installers.sysadmintools.dagu as daguinstaller
import freeflowuniverse.crystallib.clients.daguclient

pub fn (mut self DaguServer[Config]) dag_path(name string) string {
	return '${os.home_dir()}/dags/${texttools.name_fix(name)}.yaml'
}

fn (mut self DaguServer[Config]) installargs() daguinstaller.InstallArgs {
	mut cfg := self.config() or { panic(err) }
	return daguinstaller.installargs(
		homedir: cfg.homedir
		username: cfg.username
		password: cfg.password
		secret: cfg.secret
		title: cfg.title
	)
}

pub fn (mut self DaguServer[Config]) start() ! {
	mut installargs := self.installargs()
	daguinstaller.start(installargs)!
}

pub fn (mut self DaguServer[Config]) install() ! {
	mut installargs := self.installargs()
	daguinstaller.install(installargs)!
	// configure a client to the local instance
	// the name will be 'local'
	self.client()! // just to check it works
}

pub fn (mut self DaguServer[Config]) client() !daguclient.DaguClient {
	mut installargs := self.installargs()
	mut cfg := self.config() or { panic(err) }
	// configure a client to the local instance
	// the name will be 'local'
	return daguclient.get('local',
		url: 'http://${cfg.host}:${cfg.port}'
		username: 'admin'
		password: cfg.password
		apisecret: cfg.secret
	)!
}

pub fn (mut self DaguServer[Config]) is_running() !bool {
	mut installargs := self.installargs()
	return daguinstaller.check(installargs)!
}

pub fn (mut self DaguServer[Config]) restart() ! {
	self.stop()!
	self.start()!
}

pub fn (mut self DaguServer[Config]) stop() ! {
	daguinstaller.stop()!
}
