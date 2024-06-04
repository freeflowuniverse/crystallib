module caddy

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools

@[heap]
pub struct Caddy {
pub mut:
	sites []Site
	path  pathlib.Path
}

@[params]
pub struct CaddyArgs {
pub mut:
	reset bool   = true
	path  string = '/etc/caddy'
}

pub fn new(args CaddyArgs) !Caddy {
	mut caddyobj := Caddy{
		path: pathlib.get_file(path: '${args.path}/Caddyfile', create: true)!
	}
	return caddyobj
}

pub fn (mut caddy Caddy) get(name_ string) !Site {
	name := texttools.name_fix(name_)
	if site in caddy.sites {
		if site.name == name {
			return site
		}
	}
	return error("Can't find process with name ${name}")
}

pub fn (mut caddy Caddy) exists(name_ string) bool {
	name := texttools.name_fix(name_)
	if site in caddy.sites {
		if site.name == name {
			return true
		}
	}
	return false
}
