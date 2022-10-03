module books

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.params
import v.embed_file

enum SitesState {
	init
	initdone
	ok
}

[heap]
pub struct Sites {
pub mut:
	sites          map[string]&Site
	config         Config
	state          SitesState
	embedded_files []embed_file.EmbedFileData
}

pub struct SiteNewArgs {
	name string
	path string
}

// only way how to get to a new page
pub fn (mut sites Sites) site_new(args SiteNewArgs) ?&Site {
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
		name: texttools.name_fix_no_underscore_no_ext(name)
		path: p
		sites: &sites
	}
	sites.sites[site.name] = &site
	return sites.sites[site.name]
}

fn (mut sites Sites) scan_recursive(mut path pathlib.Path) ? {
	sites.init()?
	// $if debug{println(" - sites scan recursive: $path.path")}
	if path.is_dir() {
		if path.file_exists('.site') {
			mut name := path.name()
			mut sitefilepath := path.file_get('.site')?
			// now we found a site we need to add
			content := sitefilepath.read()?
			if content.trim_space() != '' {
				// means there are params in there
				mut params_ := params.text_to_params(content)?
				if params_.exists('name') {
					name = params_.get('name')?
				}
			}
			println(' - site new: $path.path name:$name')
			mut s := sites.site_new(path: path.path, name: name)?
			// find all files in the site
			s.scan()?
			return
		}
		mut llist := path.list(recursive: false) or {
			return error('cannot list: $path.path \n$error')
		}
		for mut p_in in llist {
			if p_in.is_dir() {
				if p_in.path.starts_with('.') || p_in.path.starts_with('_') {
					continue
				}

				sites.scan_recursive(mut p_in) or {
					msg := 'Cannot process recursive on $p_in.path\n$err'
					// println(msg)
					return error(msg)
				}
			}
		}
	}
}

pub fn (mut sites Sites) scan(path string) ? {
	mut p := pathlib.get_dir(path, false)?
	sites.scan_recursive(mut p)?
}

pub fn (mut sites Sites) get(name string) ?&Site {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	if namelower in sites.sites {
		return sites.sites[namelower]
	}
	return error('could not find site with name:$name')
}

// fix all loaded sites
pub fn (mut sites Sites) fix() ? {
	if sites.state == .ok {
		return
	}
	for _, mut site in sites.sites {
		site.fix()?
	}
}
