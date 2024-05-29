module mediacms

// import freeflowuniverse.crystallib.installers.zinit as zinitinstaller
// import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.installers.docker
import freeflowuniverse.crystallib.ui.console

pub fn install(args Config) ! {
	checkplatform()!
	docker.install()!

	if osal.done_exists('mediacms_install') {
		console.print_header('mediacms already installed')
		return
	}

	docker.install()!

	build(args)!

	osal.done_set('mediacms_install', 'OK')!

	console.print_header('mediacms installed properly.')
}
