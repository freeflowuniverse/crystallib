module imagemagick

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import os

// this gets the name of the directory
const installername = os.base(os.dir(@FILE))

// install imagemagick will return true if it was already installed
pub fn install() ! {
	console.print_header('install ${imagemagick.installername}')
	if !osal.done_exists('install_${imagemagick.installername}') {
		osal.package_install('imagemagick')!
		osal.done_set('install_${imagemagick.installername}', 'OK')!
	}
	console.print_header('${imagemagick.installername} already done')
}
