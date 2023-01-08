module books

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.params

enum SitesState {
	init
	initdone
	ok
}

[heap]
pub struct SitesConfig {
pub mut: // pointer to site
	heal bool = true
}

[heap]
pub struct Sites {
pub mut:
	sites  map[string]&Site
	state  SitesState
	config SitesConfig
}

pub struct SiteNewArgs {
	name string
	path string
}

// only way how to get to a new page
pub fn (mut sites Sites) site_new(args SiteNewArgs) !&Site {
	mut p := pathlib.get_file(args.path, false)! // makes sure we have the right path
	if !p.exists() {
		return error('cannot find site on path: ${args.path}')
	}
	p.path_normalize()! // make sure its all lower case and name is proper
	mut name := args.name
	if name == '' {
		name = p.name()
	}
	mut site := Site{
		name: texttools.name_fix_no_ext(name)
		path: p
		sites: &sites
	}
	sites.sites[site.name.replace('_', '')] = &site
	return &site
}

fn (mut sites Sites) scan_recursive(mut path pathlib.Path) ! {
	// $if debug{println(" - sites scan recursive: $path.path")}
	if path.is_dir() {
		if path.file_exists('.site') {
			mut name := path.name()
			mut sitefilepath := path.file_get('.site')!
			// now we found a site we need to add
			content := sitefilepath.read()!
			if content.trim_space() != '' {
				// means there are params in there
				mut params_ := params.text_to_params(content)!
				if params_.exists('name') {
					name = params_.get('name')!
				}
			}
			println(' - site new: ${path.path} name:${name}')
			mut s := sites.site_new(path: path.path, name: name)!
			// find all files in the site
			s.scan()!
			return
		}
		mut llist := path.list(recursive: false) or {
			return error('cannot list: ${path.path} \n${error}')
		}
		for mut p_in in llist {
			if p_in.is_dir() {
				if p_in.path.starts_with('.') || p_in.path.starts_with('_') {
					continue
				}

				sites.scan_recursive(mut p_in) or {
					msg := 'Cannot process recursive on ${p_in.path}\n${err}'
					// println(msg)
					return error(msg)
				}
			}
		}
	}
}

pub fn (mut sites Sites) scan(path string) ! {
	mut p := pathlib.get_dir(path, false)!
	sites.scan_recursive(mut p)!
}

pub fn (mut sites Sites) exists(name string) bool {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	if namelower in sites.sites {
		return true
	}
	return false
}

pub fn (mut sites Sites) get(name string) !&Site {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	if namelower in sites.sites {
		return sites.sites[namelower]
	}
	return error('could not find site with name:${name}')
}

// fix all loaded sites
pub fn (mut sites Sites) fix() ! {
	if sites.state == .ok {
		return
	}
	for _, mut site in sites.sites {
		site.fix()!
	}
}

pub fn (mut sites Sites) sitenames() []string {
	mut res := []string{}
	for key, _ in sites.sites {
		res << key
	}
	res.sort()
	return res
}

// walk over all sites see if we can find the image
// return string if it exists otherwise empty
// the string name (returned argument) is the image with the site in form sitename:imagename
// pub fn (mut sites Sites) image_name_find(name string) !string {
// 	sitename, namelower := get_site_and_obj_name(name, true)!
// 	if sitename != '' {
// 		panic('should not happen, sitename need to be empty')
// 	}
// 	for _, mut site2 in sites.sites {
// 		if site2.image_exists(namelower) {
// 			return '${site2.name}:${name}'
// 		}
// 	}
// 	return ''
// }

//internal function
fn (mut sites Sites) site_get_from_object_name(name string) !&Site {
	sitename, _ := get_site_and_obj_name(name, true)!
	if sitename == '' {
		return error("Specify the site name, format to use is: 'site:object', specified:'$name")
	}
	if sitename in sites.sites {
		// means site exists
		mut site3 := sites.sites[sitename]
		return site3
	}
	sitenames := sites.sitenames().join('\n- ')
	msg := 'Cannot find site with name:${sitename} \nKnown sitenames are:\n\n${sitenames}'
	return error(msg)
}

// get the page 
// the site name needs to be specified
pub fn (mut sites Sites) page_get(name string) !&Page {
	_, namelower := get_site_and_obj_name(name, true)!
	mut site :=sites.site_get_from_object_name(name)!
	return site.page_get(namelower)!
}

// get the image 
// the site name needs to be specified
pub fn (mut sites Sites) image_get(name string) !&File {
	_, namelower := get_site_and_obj_name(name, true)!
	mut site :=sites.site_get_from_object_name(name)!
	return site.image_get(namelower)!
}


//will walk over all sites, untill it finds the image or the file
pub fn (mut sites Sites) image_file_find_over_sites(name string) !&File {
	mut _, namelower := get_site_and_obj_name(name, false)!	
	for _,mut site in sites.sites{
		if site.image_exists(namelower){
			return site.image_get(namelower)
		}
		if site.file_exists(namelower){
			return site.file_get(namelower)
		}		
	}
	return error("could not find image over all sites: $name")
}


// get the file 
// the site name needs to be specified
pub fn (mut sites Sites) file_get(name string) !&File {
	_, namelower := get_site_and_obj_name(name, true)!
	mut site :=sites.site_get_from_object_name(name)!
	return site.file_get(namelower)!
}
