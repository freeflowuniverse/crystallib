module publisher

import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.publisher.config
// import path

[heap]
struct Site {
pub mut: // id and index in the Publisher.sites array
	// not in json if we would serialize
	errors []SiteError
	path   string
	name   string // is the shortname!!!
	pages       map[string]Page
	files       map[string]File
	defs        map[string]Def
	state         SiteState
	config        &config.SiteConfig
	sidebars_last []&Page
}

pub enum SiteErrorCategory {
	duplicatefile
	duplicatepage
	emptypage
	unknown
	sidebar
}

struct SiteError {
pub:
	path  string
	error string
	cat   SiteErrorCategory
}

pub enum SiteState {
	init
	ok
	error
	loaded
}

struct SiteRepoConfig {
	// name of the wiki site
	name string
	// depends on which other wiki sites
	depends      []string
	wordreplace  []string
	filereplace  []string
	sitereplace  []string
	error_ignore []string
}

pub fn (mut site Site) error_ignore_check(name string) bool {
	// for mut item in site.config.error_ignore {
	// 	if texttools.name_fix(name) == texttools.name_fix(item) {
	// 		return true
	// 	}
	// }
	return false
}

fn (mut site Site) error(pathrelative string, errormsg string, cat SiteErrorCategory) {
	site.errors << SiteError{
		path: pathrelative
		error: errormsg
		cat: cat
	}
	println(' - SITE ERROR: $pathrelative -> $errormsg')
}

pub fn (site Site) page_get(name string) ?&Page {
	mut namelower := texttools.name_fix(name)
	if namelower in site.pages {
		return publisher.page_get_by_id(site.pages[namelower])
	}
	return error('cannot find page with name $name')
}

pub fn (site Site) file_get(name string) ?&File {
	if name.ends_with('.png') || name.ends_with('.jpeg') || name.ends_with('.jpg') {
		return site.image_get(name, mut publisher)
	}
	mut namelower := texttools.name_fix(name)
	if namelower in site.files {
		file := publisher.file_get_by_id(site.files[namelower])?
		return file
	}
	return error('cannot find file with name $name')
}

pub fn (site Site) image_get(name string) ?&File {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	if namelower in site.images {
		file := publisher.file_get_by_id(site.images[namelower])?
		return file
	}
	return error('cannot find image with name $name')
}

pub fn (site Site) page_exists(name string) bool {
	mut namelower := texttools.name_fix(name)
	return namelower in site.pages
}

pub fn (site Site) image_exists(name string) bool {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	return namelower in site.images
}

pub fn (site Site) file_exists(name string) bool {
	namelower := texttools.name_fix(name)
	return namelower in site.files
}
