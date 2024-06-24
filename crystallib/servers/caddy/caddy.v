module caddy

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.clients.dagu
import freeflowuniverse.crystallib.core.texttools

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
}

pub fn (mut self Caddy[Config]) start() ! {
	osal.exec(cmd: 'dagu start')!
}

pub fn (mut self Caddy[Config]) stop() ! {
	osal.exec(cmd: 'dagu stop')!
}
