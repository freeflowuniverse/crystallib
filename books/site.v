module books

// import os
import freeflowuniverse.crystallib.pathlib { Path }
import freeflowuniverse.crystallib.markdowndocs

enum SiteType {
	book
	wiki
	web
}

enum SiteState {
	init
	initdone
	scanned
	fixed
	ok
}

[heap]
pub struct Site {
pub:
	name     string
	sitetype SiteType
pub mut:
	title  string
	sites  &Sites           [str: skip] // pointer to sites
	pages  map[string]&Page
	files  map[string]&File
	images map[string]&File
	path   Path
	errors []SiteError
	site   SiteState
}

// walk over one specific site, find all files and pages
pub fn (mut site Site) scan() ! {
	site.scan_internal(mut site.path)!
}

pub enum SiteErrorCat {
	unknown
	image_double
	file_double
	file_not_found
	image_not_found
	page_double
	page_not_found
	sidebar
}

pub struct SiteErrorArgs {
pub:
	path Path
	msg  string
	cat  SiteErrorCat
}

pub struct SiteError {
pub mut:
	path Path
	msg  string
	cat  SiteErrorCat
}

pub fn (mut site Site) error(args SiteErrorArgs) {
	site.errors << SiteError{
		path: args.path
		msg: args.msg
		cat: args.cat
	}
}

pub fn (mut site Site) file_get(name string) !&File {
	mut sitename, namelower := get_site_and_obj_name(name, false)!
	namesmallest := namelower.replace('_', '')
	if sitename == '' {
		if namesmallest in site.files {
			return site.files[namesmallest]
		}
	} else {
		if sitename in site.sites.sites {
			// means site exists
			mut site2 := site.sites.sites[sitename]
			return site2.file_get(namelower)
		} else {
			sitenames := site.sites.sitenames().join('\n- ')
			return error('Cannot find site with name:${sitename} \nKnown sitenames are:\n\n${sitenames}')
		}
	}
	return error('Could not find file with name: ${namelower} for site:${site.name}')
}

pub fn (mut site Site) image_get(name string) !&File {
	sitename, mut namelower := get_site_and_obj_name(name, true)!
	namelower = namelower.replace('_', '')
	// make sure we look for images independent of extension and ending _
	if sitename == '' {
		if namelower in site.images {
			return site.images[namelower]
		}
	} else {
		if sitename in site.sites.sites {
			// means site exists
			mut site2 := site.sites.sites[sitename]
			return site2.image_get(namelower)!
		} else {
			sitenames := site.sites.sitenames().join('\n- ')
			msg := 'Cannot find site with name:${sitename} \nKnown sitenames are:\n\n${sitenames}'
			return error(msg)
		}
	}
	msg2 := 'Could not find image with name: ${namelower}'
	return error(msg2)
}

pub fn (mut site Site) image_exists(name string) bool {
	sitename, mut namelower := get_site_and_obj_name(name, true) or { return false }
	namelower = namelower.replace('_', '')
	// make sure we look for images independent of extension and ending _
	if sitename == '' {
		if namelower in site.images {
			return true
		}
	} else {
		if sitename in site.sites.sites {
			// means site exists
			mut site2 := site.sites.sites[sitename]
			return site2.image_exists(namelower)
		}
	}
	return false
}

pub fn (mut site Site) file_exists(name string) bool {
	site.file_get(name) or { return false }
	return true
}

// param look_in_sites means we will look in all sites
pub fn (mut site Site) page_get(name string) !&Page {
	sitename, mut namelower := get_site_and_obj_name(name, true)!
	namelower = namelower.trim_string_right('.md')
	namesmallest := namelower.replace('_', '')

	if sitename == '' {
		if namesmallest in site.pages {
			// println(" pgetget: $namesmallest")
			return site.pages[namesmallest]
		}
	} else {
		if sitename in site.sites.sites {
			// means site exists
			mut site2 := site.sites.sites[sitename]
			return site2.page_get(namelower)
		} else {
			sitenames := site.sites.sitenames().join('\n- ')
			return error("Cannot find site with name:'${sitename}' \nKnown sitenames are:\n\n${sitenames}")
		}
	}
	return error("Could not find page with name: '${namelower}' for site:'${site.name}'")
}

// param look_in_sites means we will look in all sites
pub fn (mut site Site) page_exists(name string) bool {
	site.page_get(name) or { return false }
	return true
}

// only way how to get to a new page
pub fn (mut site Site) page_new(mut p Path) !&Page {
	if !p.exists() {
		return error('cannot find page with path ${p.path}')
	}
	p.path_normalize()! // make sure its all lower case and name is proper
	mut page := Page{
		path: p
		site: &site
	}
	if !page.path.path.ends_with('.md') {
		return error('page ${page} needs to end with .md')
	}
	// println(" ---------- $page.path.path")
	// parse the markdown of the page
	mut parser := markdowndocs.get(p.path) or { panic('cannot parse,${err}') }
	page.doc = parser.doc
	page.name = p.name_fix_no_ext()
	page.pathrel = p.path_relative(site.path.path)!
	page.pathrel = page.pathrel.trim('/')
	_, namelower := get_site_and_obj_name(p.path, false)!
	namesmallest := namelower.replace('_', '')
	site.pages[namesmallest] = &page
	return site.pages[namesmallest]
}

// only way how to get to a new file
fn (mut site Site) file_new(mut p Path) ! {
	p.path_normalize()! // make sure its all lower case and name is proper
	if !p.exists() {
		return error('cannot find file for path in site: ${p}')
	}
	if p.name().starts_with('.') {
		panic('should not start with . \n${p}')
	}
	_, namelower := get_site_and_obj_name(p.path, false)!
	mut ff := File{
		path: p
		site: &site
	}
	ff.init()
	namesmallest := namelower.replace('_', '')
	site.files[namesmallest] = &ff
}

// only way how to get to a new image
fn (mut site Site) image_new(mut p Path) ! {
	if !p.exists() {
		return error('cannot find image for path in site: ${p.path}')
	}
	if p.name().starts_with('.') {
		panic('should not start with . \n${p}')
	}

	if site.image_exists(p.name()) {
		// remove this one
		mut file_double := site.image_get(p.name())!
		mut path_double := file_double.path
		if p.path.len > path_double.path.len {
			p.delete()!
		} else {
			path_double.delete()!
			file_double.path = p // reset the path so the shortest one remains
		}

		return
	}

	_, namelower := get_site_and_obj_name(p.path, true)!
	mut ff := File{
		path: p
		site: &site
	}
	ff.init()
	namesmallest := namelower.replace('_', '')
	site.images[namesmallest] = &ff
}

pub fn (mut site Site) fix() ! {
	for _, mut page in site.pages {
		page.fix()!
	}
	site.errors_report()!
}

pub fn (mut site Site) pagenames() []string {
	mut res := []string{}
	for key, _ in site.pages {
		res << key
	}
	res.sort()
	return res
}

pub fn (mut site Site) errors_report() ! {
	mut p := pathlib.get('${site.path.path}/errors.md')
	if site.errors.len == 0 {
		p.delete()!
		return
	}
	c := $tmpl('template/errors_site.md')
	p.write(c)!
}
