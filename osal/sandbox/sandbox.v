module sandbox

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.gittools
import os
import json

// install runc
pub fn install() ! {
	if !(osal.cmd_exists('runc')) {
		println('installing runc')
		osal.upgrade()!
		osal.package_install('runc,debootstrap')!
	}
}
