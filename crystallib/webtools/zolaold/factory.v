module zola

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.data.ourtime
import freeflowuniverse.crystallib.ui.console
// import time
import os

@[heap]
pub struct Zola[T] {
	play.Base[T] // pub mut:	
	// sites           []&ZolaSite                 @[skip; str: skip]
}

pub struct Config {
	play.ConfigBase
pub mut:
	configtype   string = 'mdbooks' // needs to be defined	
	path_build   string = '${os.home_dir()}/hero/var/wsbuild'
	path_publish string = '${os.home_dir()}/hero/www'
	nodeaddr     string
	sshkey       string
}

pub fn get(args play.PlayArgs) !Zola[Config] {
	mut zola := Zola[Config]{
		instance: args.instance
	}
	zola.init(args)!
	return zola
}
