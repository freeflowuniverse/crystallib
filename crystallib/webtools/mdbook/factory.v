module mdbook

// import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.base
import os

@[heap]
pub struct MDBooks[T] {
	base.BaseConfig[T]
}

pub struct Config {
	base.ConfigBase
pub mut:
	configtype   string = 'mdbooks' // needs to be defined	
	path_build   string = '${os.home_dir()}/hero/var/mdbuild'
	path_publish string = '${os.home_dir()}/hero/www/info'
}

pub fn get(args base.SessionNewArgs) !MDBooks[Config] {
	mut books := MDBooks[Config]{}
	books.init(args)!

	mut cfg := books.config()!

	cfg.path_build = cfg.path_build.replace('~', os.home_dir())
	cfg.path_publish = cfg.path_publish.replace('~', os.home_dir())

	return books
}
