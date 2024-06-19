module caddy

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.crypt.secrets
import freeflowuniverse.crystallib.installers.web.caddy as caddyinstaller
import os

// import freeflowuniverse.crystallib.ui.console

pub struct Caddy[T] {
	base.BaseConfig[T]
}

@[params]
pub struct Config {
pub mut:
	url     string // url to the caddyfile
	homedir string = '/etc/caddy'
	reset   bool
	file    CaddyFile
}

pub fn get(instance string) !Caddy[Config] {
	mut self := Caddy[Config]{}
	self.init('caddy', instance, .get)!
	return self
}

// set the configuration, will make defaults for passwd & secret
pub fn configure(instance string, cfg_ Config) !Caddy[Config] {
	mut cfg := cfg_
	mut self := Caddy[Config]{}

	mut file := pathlib.get_file(path: '${cfg.homedir}/Caddyfile')!
	file.write(cfg.file.export()!)!

	caddyinstaller.install(
		start: true
		homedir: cfg.homedir
		reset: cfg.reset
	)!

	self.init('caddy', instance, .set, cfg)!

	return self
}
