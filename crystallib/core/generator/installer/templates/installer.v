module ${args.name}

// import freeflowuniverse.crystallib.installers.zinit as zinitinstaller
// import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal.gittools

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

pub fn install(args InstallArgs) ! {
	
	checkplatform()!

	if osal.done_exists('${args.name}_install') {
		println(' - ${args.name} already installed')
		return
	}

	build()!

	osal.done_set('${args.name}_install', 'OK')!

	println(' - ${args.name} installed properly.')
}
