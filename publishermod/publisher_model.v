module publishermod

import despiegk.crystallib.texttools

struct Publisher {
mut:
	gitlevel int
pub mut:
	sites      []Site
	pages      []Page
	files      []File
	site_names map[string]int
	// maps definition name to page id
	defs     map[string]Def
	develop  bool
	replacer ReplacerInstructions
}

struct Def {
	name   string
	pageid int
}

struct ReplacerInstructions {
pub mut:
	site texttools.ReplaceInstructions
	file texttools.ReplaceInstructions
	word texttools.ReplaceInstructions
	defs texttools.ReplaceInstructions
}

pub fn (mut publisher Publisher) site_get_by_id(id int) ?&Site {
	if id > publisher.sites.len {
		return error('cannot get site with id: $id because not enough sites in the list')
	}
	return &publisher.sites[id]
}

pub fn (mut publisher Publisher) page_get_by_id(id int) ?&Page {
	if id > publisher.pages.len {
		return error('cannot get page with id: $id because not enough pages in the list')
	}
	return &publisher.pages[id]
}

pub fn (mut publisher Publisher) file_get_by_id(id int) ?&File {
	if id > publisher.files.len {
		return error('cannot get file with id: $id because not enough files in the list')
	}
	return &publisher.files[id]
}

////////////////////////////////////////////////////////////////

pub fn (mut publisher Publisher) site_exists(name string) bool {
	name2 := name_fix(name)
	return name2 in publisher.site_names
}

pub fn (mut publisher Publisher) file_exists(name string) bool {
	sitename, itemname := name_split(name) or { panic(err) }
	if sitename == '' {
		for site in publisher.sites {
			if itemname in site.files {
				return true
			}
		}
		return false
	} else {
		site := publisher.site_get(sitename) or { panic(err) }
		return itemname in site.files
	}
}

pub fn (mut publisher Publisher) page_exists(name string) bool {
	mut sitename, itemname := name_split(name) or { return false }
	if sitename == '' {
		for site in publisher.sites {
			if itemname in site.pages {
				return true
			}
		}
		return false
	} else {
		site := publisher.site_get(sitename) or { return false }
		return itemname in site.pages
	}
}

////////////// GET BY NAME

pub fn (mut publisher Publisher) site_get(namefull string) ?&Site {
	sitename := name_fix(namefull)
	if sitename in publisher.site_names {
		mut site := publisher.site_get_by_id(publisher.site_names[sitename]) or {
			// println(publisher.site_names)
			return error('cannot find site: $sitename')
		}
		return site
	}
	return error('cannot find site: $sitename')
}

// namefull is name with : if needed
pub fn (mut publisher Publisher) files_get(namefull string) []&File {
	sitename, itemname := name_split(namefull) or { panic(err) }
	site_id := publisher.site_names[sitename]
	mut res := []&File{}
	for x in 0 .. publisher.files.len {
		file := publisher.files[x]
		if sitename != '' && file.site_id != site_id {
			// no need to check more, check next file
			continue
		}
		if file.name == itemname {
			file_found := publisher.file_get_by_id(x) or { panic(err) }
			if !(file_found in res) {
				res << file_found
			}
		}
	}
	return res
}

// namefull is name with : if needed
pub fn (mut publisher Publisher) pages_get(namefull string) []&Page {
	sitename, itemname := name_split(namefull) or { panic(err) }
	site_id := publisher.site_names[sitename]
	mut res := []&Page{}
	for x in 0 .. publisher.pages.len {
		page := publisher.pages[x]
		if sitename != '' && page.site_id != site_id {
			// no need to check more, check next page
			continue
		}
		if page.name == itemname {
			page_found := publisher.page_get_by_id(x) or { panic(err) }
			if !(page_found in res) {
				res << page_found
			}
		}
	}
	return res
}

// name in form: 'sitename:filename' or 'filename'
pub fn (mut publisher Publisher) file_get(namefull string) ?&File {
	sitename, itemname := publisher.name_split_alias(namefull) ?
	println(" >> file_get:'$sitename':'$itemname'")
	res := publisher.files_get(namefull)
	if res.len == 0 {
		return error("Could not find file: '$namefull'")
	} else if res.len > 1 {
		return error("Found more than 1 file with name: '$namefull'")
	} else {
		return res[0]
	}
}

// name in form: 'sitename:pagename' or 'pagename'
pub fn (mut publisher Publisher) page_get(namefull string) ?&Page {
	sitename, itemname := publisher.name_split_alias(namefull) ?
	println(" >> page_get:'$sitename':'$itemname'")
	res := publisher.pages_get(namefull)
	if res.len == 0 {
		return error("Could not find page: '$namefull'")
	} else if res.len > 1 {
		return error("Found more than 1 page with name: '$namefull'")
	} else {
		return res[0]
	}
}

enum ExistState {
	ok
	double
	notfound
	namespliterror
	error
}

// try and get if page exists and return state of how it did exist
pub fn (mut publisher Publisher) page_exists_state(name string) ExistState {
	_ := publisher.page_get(name) or {
		if err.contains('not find page') {
			return ExistState.notfound
		} else if err.contains('site not found') {
			return ExistState.notfound
		} else if err.contains('more than 1 page') {
			return ExistState.double
		} else if err.contains('namesplit issue') {
			return ExistState.namespliterror
		}
		return ExistState.error
	}
	return ExistState.ok
}

// try and get if file exists and return state of how it did exist
pub fn (mut publisher Publisher) file_exists_state(name string) ExistState {
	_ := publisher.file_get(name) or {
		if err.contains('not find file') {
			return ExistState.notfound
		} else if err.contains('site not found') {
			return ExistState.notfound
		} else if err.contains('more than 1 file') {
			return ExistState.double
		} else if err.contains('namesplit issue') {
			return ExistState.namespliterror
		}
		return ExistState.error
	}
	return ExistState.ok
}

// try and get if page or file exists and return state of how it did exist
pub fn (mut publisher Publisher) page_file_exists_state(name string, ispage bool) ExistState {
	if ispage {
		return publisher.page_exists_state(name)
	} else {
		return publisher.file_exists_state(name)
	}
}
