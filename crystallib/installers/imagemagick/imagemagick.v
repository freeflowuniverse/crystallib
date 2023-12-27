module imagemagick

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import os
import freeflowuniverse.crystallib.installers.base
import process

// this gets the name of the directory
const installername = os.base(os.dir(@FILE))

// install imagemagick will return true if it was already installed
pub fn install() ! {
	console.print_header('package_install install ${imagemagick.installername}')
	if !osal.done_exists('install_${imagemagick.installername}') {
		if osal.platform() == .ubuntu {
			osal.package_install(name: 'imagemagick')!
		} else {
			return error('only ubuntu and osx supported for now')
		}
		osal.done_set('install_${imagemagick.installername}', 'OK')!
	}
	console.print_header('${imagemagick.installername} already done')
}
