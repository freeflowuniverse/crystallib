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

///////////// PAGE/IMAGE/FILE GET

// format of name is $sitename:$pagename or $pagename
// look if we can find page in the local site is site name not specified
// if sitename specified will look for page in that specific site
pub fn (mut site Site) page_get(name string) !&Page {
	sitename, mut namelower := get_site_and_obj_name(name, true)!
	namelower = namelower.trim_string_right('.md')
	namelower = namelower.replace('_', '')
	if sitename == '' {
		if namelower in site.pages {
			return site.pages[namelower]
		}
	} else {
		if sitename in site.sites.sites {
			// means site exists
			mut site2 := site.sites.sites[sitename]
			return site2.page_get(namelower)!
		}
	}
	msg2 := "Could not find page with name:'${namelower}'' in site:'${site.name}'"
	return error(msg2)
}

// format of name is $sitename:$imagename or $imagename
// look if we can find image in the local site if site name not specified
// if sitename specified will look for image in that specific site
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
		}
	}
	msg2 := "Could not find image with name:'${namelower}'' in site:'${site.name}'"
	return error(msg2)
}

// format of name is $sitename:$filename or $filename
// look if we can find file in the local site is site name not specified
// if sitename specified will look for file in that specific site
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

///////////// EXISTS

// check if page exists in the local site, will ignore the mentioned site name
pub fn (mut site Site) page_exists(name string) bool {
	sitename, mut namelower := get_site_and_obj_name(name, true) or { panic(err) }
	namelower = namelower.trim_string_right('.md')
	namelower = namelower.replace('_', '')
	if sitename == '' {
		if namelower in site.pages {
			return true
		}
	}
	return false
}

// check if image exists in the local site, will ignore the mentioned site name
pub fn (mut site Site) image_exists(name string) bool {
	sitename, mut namelower := get_site_and_obj_name(name, true) or { panic(err) }
	namelower = namelower.replace('_', '')
	if sitename == '' {
		if namelower in site.images {
			return true
		}
	}
	return false
}

// check if file exists in the local site, will ignore the mentioned site name
pub fn (mut site Site) file_exists(name string) bool {
	sitename, mut namelower := get_site_and_obj_name(name, true) or { panic(err) }
	namelower = namelower.replace('_', '')
	if sitename == '' {
		if namelower in site.files {
			return true
		}
	}
	return false
}

// add a page to the site, specify existing path
// the page will be parsed as markdown
pub fn (mut site Site) page_new(mut p Path) !&Page {
	if !p.exists() {
		return error('cannot find page with path ${p.path}')
	}
	p.path_normalize()! // make sure its all lower case and name is proper
	if !p.path.ends_with('.md') {
		return error('page ${p.path} needs to end with .md')
	}
	mut doc := markdowndocs.new(path: p.path) or { panic('cannot parse,${err}') }

	mut page := Page {
		doc: &doc
		pathrel: p.path_relative(site.path.path)!.trim('/')
		name: p.name_fix_no_ext()
		path: p
		site: &site
		readonly: false
	}
	_, namelower := get_site_and_obj_name(p.path, false)!
	namesmallest := namelower.replace('_', '')
	site.pages[namesmallest] = &page
	return site.pages[namesmallest]
}

// add a file to the site, specify existing path
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

// add a image to the site, specify existing path
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

// go over all pages, fix the links, check the images are there
pub fn (mut site Site) fix() ! {
	$if debug {
		println(' --- site fix: ${site.name}')
	}
	for _, mut page in site.pages {
		page.fix()!
	}
	site.errors_report()!
}

// return all pagenames for a site
pub fn (mut site Site) pagenames() []string {
	mut res := []string{}
	for key, _ in site.pages {
		res << key
	}
	res.sort()
	return res
}

// write errors.md in the site, this allows us to see what the errors are
pub fn (mut site Site) errors_report() ! {
	mut p := pathlib.get('${site.path.path}/errors.md')
	if site.errors.len == 0 {
		p.delete()!
		return
	}
	c := $tmpl('template/errors_site.md')
	p.write(c)!
}
