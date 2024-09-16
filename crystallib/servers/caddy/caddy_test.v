module caddy

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.servers.caddy.security
import os

pub fn test_caddy_start() ! {
	mut c := get('')!
	c.start()!
}

pub fn test_caddy_stop() ! {
	mut c := get('')!
	c.stop()!
}

pub fn test_caddy_restart() ! {
	mut c := get('')!
	c.restart()!
}
