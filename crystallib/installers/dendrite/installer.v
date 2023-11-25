module dendrite
import freeflowuniverse.crystallib.installers.zinit as zinitinstaller
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib



pub fn install() ! {

	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}

	if osal.done_exists('dendrite_install') {		
		println(" - dendrite binaraies already installed")
		return
	}

	build()!

	osal.done_set('dendrite_install',"OK") !

	println(" - dendrite installed properly.")

}