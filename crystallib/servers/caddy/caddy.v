module caddy

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.sysadmin.startupmanager
import os

// Restart the Caddy
pub fn (mut self Caddy[Config]) restart() ! {
	self.stop()!
	self.start()!
}

pub fn (mut self Caddy[Config]) reverse_proxy(address Address, args ReverseProxy) ! {
	mut cfg := self.config()!
	cfg.file.reverse_proxy(address, args)!
}

pub fn (mut self Caddy[Config]) file_server(addresses []Address, args FileServer) ! {
	mut cfg := self.config()!
	cfg.file.file_server(addresses, args)!
}

pub fn (mut self Caddy[Config]) add_block(block SiteBlock) ! {
	mut cfg := self.config()!
	cfg.file.add_site_block(block)
}

pub fn (mut self Caddy[Config]) generate() ! {
	mut cfg := self.config()!
	content := cfg.file.export()!
	mut file := pathlib.get_file(path: '${cfg.homedir}/Caddyfile')!
	file.write(content) or { panic('failed to write ${err}') }
}

pub fn (mut self Caddy[Config]) start() ! {
	mut cfg := self.config()!
	console.print_header('caddy start')

	if cfg.homedir == '' {
		cfg.homedir = '/tmp/caddy'
	}

	if !os.exists('/etc/caddy/Caddyfile') {
		return error("didn't find caddyfile")
	}

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
