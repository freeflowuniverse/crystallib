module juggler

import os
import time
import freeflowuniverse.crystallib.servers.caddy
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.servers.daguserver
import freeflowuniverse.crystallib.installers.sysadmintools.dagu as daguinstaller
import freeflowuniverse.crystallib.installers.web.caddy as caddyinstaller

const instance_name = 'testinstance'



pub fn test_get() ! {
	j := get(name: instance_name)!
	assert daguinstaller.is_installed(daguinstaller.version)!
	assert caddyinstaller.is_installed(caddyinstaller.version)!
}

pub fn test_configure() ! {
	mut j := configure(
		name: instance_name
		username: 'admin'
		password: 'testpassword'
		url: 'https://git.ourworld.tf/projectmycelium/itenv'
	)!
	spawn j.run(8084)
}
