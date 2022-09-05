module books

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools

[heap]
struct Sites {
pub mut:
	sites  map[string]Site
	config Config
}

pub struct SiteNewArgs {
	name string
	path string
}

// only way how to get to a new page
pub fn (mut sites Sites) site_new(args SiteNewArgs) ?Site {
	mut p := pathlib.get_file(args.path, false)? // makes sure we have the right path
	if !p.exists() {
		return error('cannot find site on path: $args.path')
	}
	p.namefix()? // make sure its all lower case and name is proper
	mut name := args.name
	if name == '' {
		name = p.name()
	}
	mut site := Site{
		name: texttools.name_fix(name)
		path: p
		sites: &sites
	}
	sites.sites[site.name]=site
	return site
}

// walk over the sites and scan for files and markdown docs
pub fn (mut sites Sites) scan() ? {
	for _, mut site in sites.sites {
		site.scan()?
	}
}

pub fn (mut sites Sites) fix() ? {
	for _, mut site in sites.sites {
		site.fix()?
	}
}


