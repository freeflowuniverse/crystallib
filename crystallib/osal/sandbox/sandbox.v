module sandbox

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.osal.gittools
import os
import json

// install runc
pub fn install() ! {
	if !(osal.cmd_exists('runc')) || !(osal.cmd_exists('debootstrap')) {
		println('installing runc')
		osal.upgrade()!
		osal.package_install('runc,debootstrap')!
	}
}
