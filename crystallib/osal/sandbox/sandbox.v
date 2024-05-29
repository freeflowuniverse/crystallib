module sandbox

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.develop.gittools
import os
import json
import freeflowuniverse.crystallib.ui.console

// install runc
pub fn install() ! {
	if !(osal.cmd_exists('runc')) || !(osal.cmd_exists('debootstrap')) {
		console.print_debug('installing runc')
		osal.upgrade()!
		osal.package_install('runc,debootstrap')!
	}
}
