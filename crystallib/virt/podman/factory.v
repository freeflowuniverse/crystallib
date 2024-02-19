module podman

import freeflowuniverse.crystallib.installers.virt.podman as podmaninstaller
import freeflowuniverse.crystallib.core.play
import os

@[heap; params]
pub struct BAHFactory {
	play.Base
pub mut:
	builders        map[string]&BAHBuilder
}

pub struct NewArgs {
	play.Base
pub mut:
	install      bool = true
	reset        bool
}


pub fn new(args_ NewArgs) !BAHFactory {
	mut args := args_

	if args.install {
		podmaninstaller.install()!
	}

	mut bah:=BAHFactory{}

	return bah
}
