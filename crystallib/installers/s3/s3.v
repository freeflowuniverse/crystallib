module s3

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.zinit as zinitinstaller
import freeflowuniverse.crystallib.installers.rclone

// install s3 will return true if it was already installed
pub fn install() ! {
	base.install()!
	zinitinstaller.install()!
	rclone.install()!
	if osal.done_exists('install_s3') {
		return
	}

	build()!

	println(' - install s3')


	osal.done_set('install_s3', 'OK')!
}




