module podman

import freeflowuniverse.crystallib.installers.virt.podman as podmaninstaller
// import freeflowuniverse.crystallib.core.play

[params]
pub struct NewArgs {
pub mut:
	install      bool = true
	reset        bool
}


pub fn new(args_ NewArgs) !CEngine {
	mut args := args_

	if args.install {
		podmaninstaller.install()!
	}

	mut bah:=CEngine{}
	bah.init()!
	if args.reset{
		bah.reset_all()!
	}

	return bah
}
