module books

// import os
import freeflowuniverse.crystallib.pathlib { Path }
import freeflowuniverse.crystallib.texttools
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
	path   Path
	errors []SiteError
	site   SiteState
}

// walk over one specific site, find all files and pages
pub fn (mut site Site) scan() ? {
	site.scan_internal(mut site.path)?
}

enum SiteErrorCat {
	unknown
	image_double
	file_double
	file_not_found
	page_double
	page_not_found
	sidebar
}

struct SiteErrorArgs {
	path Path
	msg  string
	cat  SiteErrorCat
}

struct SiteError {
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

// param look_in_sites means we will look in all sites
pub fn (site Site) file_exists(name string, look_in_sites bool) bool {
	mut namelower := texttools.name_fix_keepext(name)
	if namelower in site.files {
		file := site.files[namelower]
		if file.ftype == .file {
			return true
		}
	}
	if look_in_sites {
		for _, site2 in site.sites.sites {
			if namelower in site2.files {
				file := site2.files[namelower]
				if file.ftype == .file {
					return true
				}
			}
		}
	}
	return false
}

// return file (can be regular file or image)
// param look_in_sites means we will look in all sites
pub fn (site Site) file_get(name string, look_in_sites bool) ?&File {
	mut namelower := texttools.name_fix_keepext(name)
	if namelower in site.files {
		file := site.files[namelower]
		if file.ftype == .file {
			return file
		} else {
			return error('did find file, but not an file for name:$name\n$file')
		}
	}
	if look_in_sites {
		for _, site2 in site.sites.sites {
			if namelower in site2.files {
				file := site2.files[namelower]
				if file.ftype == .file {
					return file
				} else {
					return error('did find file, but not an file for name:$name\n$file')
				}
			}
		}
	}
	return error('cannot find file with name $name')
}

// param look_in_sites means we will look in all sites
pub fn (site Site) image_get(name string, look_in_sites bool) ?&File {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	// print(" -- image_get: ${site.name}:$namelower")
	if namelower in site.files {
		file := site.files[namelower]
		if file.ftype == .image {
			// println(" + OK")
			return file
		} else {
			// println(" + ERROR")
			return error('did find file, but not an image for name:$name\n$file')
		}
	}
	if look_in_sites {
		for _, site2 in site.sites.sites {
			if namelower in site2.files {
				file := site2.files[namelower]
				if file.ftype == .image {
					// println(" + ${site.name}:OK")
					return file
				} else {
					// println(" + ${site.name}:ERROR")
					return error('did find file, but not an image for name:$name\n$file')
				}
			}
		}
	}
	// println(" + NOTFOUND")
	if name == 'videoconferencedecentral' {
		panic('456yhb')
	}
	return error('cannot find image with name $name ($namelower) lookinsites:$look_in_sites site:$site.name')
}

// param look_in_sites means we will look in all sites
pub fn (site Site) image_exists(name string, look_in_sites bool) bool {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	println(' -- image_exists: $site.name:$namelower')
	if namelower in site.files {
		file := site.files[namelower]
		if file.ftype == .image {
			return true
		}
	}
	if look_in_sites {
		for _, site2 in site.sites.sites {
			if namelower in site2.files {
				file := site2.files[namelower]
				if file.ftype == .image {
					return true
				}
			}
		}
	}
	return false
}

// param look_in_sites means we will look in all sites
pub fn (site Site) page_exists(name string, look_in_sites bool) bool {
	mut namelower := texttools.name_fix_no_md(name)
	// println(" -- page exists: $namelower")
	if namelower in site.pages {
		return true
	}
	if look_in_sites {
		for _, site2 in site.sites.sites {
			if namelower in site2.pages {
				return true
			}
		}
	}
	return false
}

// param look_in_sites means we will look in all sites
pub fn (site Site) page_get(name string, look_in_sites bool) ?&Page {
	mut namelower := texttools.name_fix_no_md(name)
	// println(" -- page get: $namelower")
	if namelower in site.pages {
		mut page := site.pages[namelower]
		return page
	}
	for _, site2 in site.sites.sites {
		if namelower in site2.pages {
			mut page2 := site2.pages[namelower]
			return page2
		}
	}
	return error('cannot find page with name $name')
}

// only way how to get to a new page
pub fn (mut site Site) page_new(mut p Path) ?&Page {
	if !p.exists() {
		return error('cannot find page with path $p.path')
	}
	p.namefix()? // make sure its all lower case and name is proper
	mut page := Page{
		path: p
		site: &site
	}
	if !page.path.path.ends_with('.md') {
		return error('page $page needs to end with .md')
	}
	// println(" ---------- $page.path.path")
	// parse the markdown of the page
	mut parser := markdowndocs.get(p.path) or { panic('cannot parse,$err') }
	page.doc = parser.doc
	page.name = p.name_fix_no_underscore_no_ext()
	page.pathrel = p.path_relative(site.path.path)?
	page.pathrel = page.pathrel.trim('/')
	site.pages[page.name] = &page
	return &page
}

// only way how to get to a new file
// needs to process links
fn (mut site Site) file_new(mut p Path) ? {
	if !p.exists() {
		return error('cannot find file for path in site: $p.path')
	}
	if p.name().starts_with('.') {
		panic('should not start with . \n$p')
	}
	p.namefix()? // make sure its all lower case and name is proper
	mut ff := File{
		path: p
		site: &site
	}
	ff.init()
	site.files[ff.name] = &ff
}

pub fn (mut site Site) fix() ? {
	for _, mut page in site.pages {
		page.fix()?
	}
}



