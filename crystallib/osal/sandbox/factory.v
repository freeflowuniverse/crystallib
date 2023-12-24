module sandbox

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.osal
import os

@[heap]
pub struct Factory {
pub mut:
	path_images  pathlib.Path
	imagesources map[string]ImageSource
}

@[params]
pub struct FactoryArgs {
pub mut:
	path_images string = '/data/containers/images'
}

pub fn new(args_ FactoryArgs) !Factory {
	mut args := args_

	mut f := Factory{
		path_images: pathlib.get_dir(path: args.path_images, create: true)!
	}
	f.init()

	return f
}

@[params]
pub struct DebootstrapArgs {
pub mut:
	imagename  string @[required]
	reset      bool   = true
	release    string = 'stable'
	repository string = 'http://deb.debian.org/debian/'
}

pub fn (mut f Factory) debootstrap(args_ DebootstrapArgs) ! {
	mut args := args_

	if args.release == '' || args.repository == '' {
		if args.imagename in f.imagesources {
			args.release = f.imagesources[args.imagename].release
			args.repository = f.imagesources[args.imagename].repository
		}
	}

	dokey := 'debootstrap.${args.imagename}'
	if args.reset {
		osal.done_delete(dokey)!
	}
	if osal.done_exists(dokey) {
		return
	}

	mut path := '${f.path_images.path}/${args.imagename}'
	mut patho := pathlib.get_dir(path: path, create: true)!
	if args.reset {
		patho.empty()!
	}
	osal.exec(cmd: 'debootstrap ${args.release} ${path} ${args.repository}', debug: true)!
	osal.done_set(dokey, 'ok')!
}
