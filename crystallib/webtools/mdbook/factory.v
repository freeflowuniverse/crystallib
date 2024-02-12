module mdbook


// import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.play
import os


@[heap]
pub struct MDBooks[T] {
	play.Base[T]
}

pub struct Config {
	play.ConfigBase
pub mut:
	configtype string = 'mdbooks' // needs to be defined	
	path_build     string = '${os.home_dir()}/hero/var/mdbuild'
	path_publish   string = '${os.home_dir()}/hero/www/info'
	nodeaddr string
	sshkey string
}

pub fn get(args play.PlayArgs) !MDBooks[Config] {

	mut books := MDBooks[Config]{}
	books.init(args)!

	mut cfg:=books.config()!

	cfg.path_build = cfg.path_build.replace('~', os.home_dir())
	cfg.path_publish = cfg.path_publish.replace('~', os.home_dir())

	return books
}
