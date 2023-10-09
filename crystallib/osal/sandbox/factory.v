module sandbox

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.osal
import os

[heap]
pub struct Factory {
pub mut:
	path_images pathlib.Path
}

[params]
pub struct FactoryArgs {
pub mut:
	path_images string = '/data/containers/images'
}

pub fn new(args_ FactoryArgs) !Factory {
	mut args := args_

	mut f := Factory{
		path_images: pathlib.get_dir(args.path_images, true)!
	}
	return f
}

[params]
pub struct DebootstrapArgs {
pub mut:
	reset bool = true
}

pub fn (mut f Factory) debootstrap(args DebootstrapArgs) ! {
	mut path := '${f.path_images.path}/lunar'
	mut patho := pathlib.get_dir(path, true)!
	if args.reset {
		patho.empty()!
	}
	osal.exec(cmd: 'debootstrap lunar ${patho.path}')!
}
