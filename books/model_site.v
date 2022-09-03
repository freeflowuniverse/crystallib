module books

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools

enum SiteType {
	book
	wiki
	web
}

[heap]
struct Site {
pub:
	name     string
	sites    &Sites   [str: skip] // pointer to sites
	sitetype SiteType
pub mut:
	pages  map[string]Page
	files  map[string]File
	path   pathlib.Path
	errors []SiteError
}

// walk over one specific site, find all files and pages
pub fn (mut site Site) scan() ? {
	site.scan_internal(mut site.path)?
}

enum ErrorCat {
	unknown
	doubleimage
	doublefile
	sidebar
}

struct SiteErrorArgs {
	path pathlib.Path
	msg  string
	cat  ErrorCat
}

struct SiteError {
	path pathlib.Path
	msg  string
	cat  ErrorCat
}

pub fn (mut site Site) error(args SiteErrorArgs) {
	site.errors << SiteError{
		path: args.path
		msg: args.msg
		cat: args.cat
	}
}

pub fn (site Site) page_get(name string) ?&Page {
	mut namelower := texttools.name_fix(name)
	if namelower in site.pages {
		mut page := site.pages[namelower]
		return &page
	}
	return error('cannot find page with name $name')
}

pub fn (site Site) file_get(name string) ?&File {
	if name.ends_with('.png') || name.ends_with('.jpeg') || name.ends_with('.jpg') {
		return site.image_get(name)
	}
	mut namelower := texttools.name_fix(name)
	if namelower in site.files {
		file := site.files[namelower]
		if file.ftype == .file {
			return &file
		} else {
			return error('did find file, but not an file for name:$name')
		}
	}
	return error('cannot find file with name $name')
}

pub fn (site Site) image_get(name string) ?&File {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	if namelower in site.files {
		file := site.files[namelower]
		if file.ftype == .image {
			return &file
		} else {
			return error('did find file, but not an image for name:$name')
		}
	}
	return error('cannot find image with name $name')
}

pub fn (site Site) page_exists(name string) bool {
	mut namelower := texttools.name_fix(name)
	return namelower in site.pages
}

pub fn (site Site) image_exists(name string) bool {
	_ := site.image_get(name) or { return false }
	return true
}

pub fn (site Site) file_exists(name string) bool {
	_ := site.file_get(name) or { return false }
	return true
}
