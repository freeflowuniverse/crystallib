module juggler

import os
import freeflowuniverse.crystallib.servers.caddy
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.servers.daguserver

pub fn get(j Juggler) !&Juggler {
	// get so is also installed
	mut c := caddy.get('juggler')!
	mut d := daguserver.get('juggler')!
	return &Juggler{
		...j
	}
}

pub struct Config {
mut:
	url      string
	reset    bool
	pull     bool
	coderoot string
}

pub fn configure(cfg Config) !&Juggler {
	repo_dir := pathlib.get_dir(path: code_get(cfg)!)!

	config_script := pathlib.get_file(path: '${repo_dir.path}/config.hero')!

	// start caddyserver
	mut c := caddy.configure('juggler')!

	// start caddyserver
	mut d := daguserver.configure('juggler',
		username: 'admin'
		password: 'planet1st'
		port: 8888
	)!

	return &Juggler{}
}

// returns the path of the fetched repo
fn code_get(cfg Config) !string {
	mut args := cfg

	if 'CODEROOT' in os.environ() && args.coderoot == '' {
		args.coderoot = os.environ()['CODEROOT']
	}

	if args.coderoot.len > 0 {
		panic('coderoot >0 not supported yet, not imeplemented.')
	}

	mut gs := gittools.get()!
	if args.url.len > 0 {
		return gs.code_get(
			pull: cfg.pull
			reset: cfg.reset
			url: cfg.url
			reload: true
		)!
	}

	return error('URL must be provided to configure juggler')
}
