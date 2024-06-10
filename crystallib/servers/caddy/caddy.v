module caddy

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.installers.web.caddy as caddyinstaller

// Restart the Caddy
pub fn (mut self Caddy[Config]) restart() ! {
	self.start()!
	self.stop()!
}

pub fn (mut self Caddy[Config]) reverse_proxy(block SiteBlock) ! {
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
	caddyinstaller.start()!
	// osal.exec(cmd:'caddy start')!
}

pub fn (mut self Caddy[Config]) stop() ! {
	osal.exec(cmd: 'caddy stop')!
}

