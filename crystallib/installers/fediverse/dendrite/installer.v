module dendrite

// import freeflowuniverse.crystallib.installers.zinit as zinitinstaller
// import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
// import freeflowuniverse.crystallib.core.pathlib

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

pub fn install(args InstallArgs) ! {
	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}

	if osal.done_exists('dendrite_install') {
		console.print_header('dendrite binaraies already installed')
		return
	}

	build()!

	osal.done_set('dendrite_install', 'OK')!

	console.print_header('dendrite installed properly.')
}
