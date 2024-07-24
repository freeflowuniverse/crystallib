module conduit

// import freeflowuniverse.crystallib.installers.zinit as zinitinstaller
// import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
// import freeflowuniverse.crystallib.core.pathlib

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
	version string
}

pub fn install(args InstallArgs) ! {
	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}

	if osal.done_exists('conduit_install') {
		console.print_header('conduit binaraies already installed')
		return
	}

	build()!

	osal.done_set('conduit_install', 'OK')!

	console.print_header('conduit installed properly.')
}
