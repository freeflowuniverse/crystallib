module peertube

// import freeflowuniverse.crystallib.installers.zinit as zinitinstaller
// import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.installers.docker

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

pub fn install(args InstallArgs) ! {
	checkplatform()!

	if osal.done_exists('peertube_install') {
		console.print_header('peertube already installed')
		return
	}

	base.install()!
	docker.install()!

	build()!

	osal.done_set('peertube_install', 'OK')!

	console.print_header('peertube installed properly.')
}
