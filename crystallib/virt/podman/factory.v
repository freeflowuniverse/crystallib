module podman

import freeflowuniverse.crystallib.installers.virt.podman as podmaninstaller
import freeflowuniverse.crystallib.installers.lang.crystallib
import freeflowuniverse.crystallib.osal
// import freeflowuniverse.crystallib.core.base

@[params]
pub struct NewArgs {
pub mut:
	install     bool = true
	reset       bool
	herocompile bool
}

pub fn new(args_ NewArgs) !CEngine {
	mut args := args_

	if !osal.is_linux() {
		return error('only linux supported as host for now')
	}

	if args.install {
		crystallib.check()! // will check if install, if not will do
		podmaninstaller.install()!
	}

	if args.herocompile {
		crystallib.hero_compile(reset: true)!
	}

	mut engine := CEngine{}
	engine.init()!
	if args.reset {
		engine.reset_all()!
	}

	return engine
}
