module peertube

// import freeflowuniverse.crystallib.installers.zinit as zinitinstaller
// import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.installers.docker

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

pub fn install(args InstallArgs) ! {
	checkplatform()!

	if osal.done_exists('peertube_install') {
		println(' - peertube already installed')
		return
	}

	base.install()!
	docker.install()!

	build()!

	osal.done_set('peertube_install', 'OK')!

	println(' - peertube installed properly.')
}
