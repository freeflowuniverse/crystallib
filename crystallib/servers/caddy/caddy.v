module caddy

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.installers.web.caddy as caddyinstaller
import freeflowuniverse.crystallib.sysadmin.startupmanager

// Restart the Caddy
pub fn (mut self Caddy[Config]) restart() ! {
	self.start()!
	self.stop()!
}

pub fn (mut self Caddy[Config]) reverse_proxy(block SiteBlock) ! {
	mut cfg := self.config()!
	cfg.file.site_blocks << block
}

pub fn (mut self Caddy[Config]) add_block(block SiteBlock) ! {
	mut cfg := self.config()!
	cfg.file.site_blocks << block
}

pub fn (mut self Caddy[Config]) generate() ! {
	mut cfg := self.config()!
	content := cfg.file.export()!
	mut file := pathlib.get_file(path: '${cfg.homedir}/Caddyfile')!
	file.write(content) or { panic('failed to write ${err}') }
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

	cmd := 'caddy run --config /etc/caddy/Caddyfile'

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

