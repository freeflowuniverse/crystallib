module caddy

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.servers.caddy.security
import os

// Restart the Caddy
pub fn (mut self Caddy[Config]) restart() ! {
	self.stop()!
	self.start()!
}

pub fn (mut self Caddy[Config]) start() ! {
	mut cfg := self.config()!
	console.print_header('caddy start')

	if cfg.homedir == '' {
		cfg.homedir = '/tmp/caddy'
	}

	if !os.exists('${cfg.homedir}/Caddyfile') {
		return error("didn't find caddyfile")
	}

	cfg.file.export('${cfg.homedir}/Caddyfile')!

	cmd := 'caddy run --config ${cfg.homedir}/Caddyfile'

	mut sm := startupmanager.get()!

	sm.start(
		name: 'caddy'
		cmd: cmd
	)!
}

pub fn (mut self Caddy[Config]) stop() ! {
	console.print_header('caddy stop')
	mut sm := startupmanager.get()!
	sm.stop('caddy')!
}

pub fn (mut self Caddy[Config]) set_caddyfile(file CaddyFile) ! {
	mut cfg := self.config()!
	cfg.file = file
}
