module publisher_core
// import despiegk.crystallib.path

import os

pub enum PageStatus {
	unknown
	ok
	error
	reprocess
}

[heap]
struct Page {
	id      int [skip]
	site_id int [skip]
mut:
	path string
pub:
	name string
pub mut:
	state           PageStatus
	errors          []PageError
	pages_included  []int // links to pages
	pages_linked    []int // links to pages
	content         string
	nrtimes_inluded int
	categories      []string
	replaced        bool
	sidebarid		int
}

pub enum PageErrorCat {
	unknown
	brokenfile
	brokenlink
	brokeninclude
	doublepage
}

struct PageError {
pub:
	line   string
	linenr int
	msg    string
	cat    PageErrorCat
}

pub fn (page Page) site_get(mut publisher &Publisher) ?&Site {
	return publisher.site_get_by_id(page.site_id)
}

pub fn (page Page) site(mut publisher &Publisher) &Site {
	mut s := publisher.site_get_by_id(page.site_id) or { panic(err) }
	return s
}

// walk over categories, see if we can find the prefix
pub fn (page Page) category_prefix_exists(prefix_ string) bool {
	prefix := prefix_.to_lower()
	for cat in page.categories {
		if cat.starts_with(prefix) {
			return true
		}
	}
	return false
}

pub fn (mut page Page) categories_add(categories []string) {
	for cat_ in categories {
		cat := cat_.to_lower()
		if !(cat in page.categories) {
			page.categories << cat
		}
	}
}

pub fn (page Page) path_relative_get(mut publisher &Publisher) string {
	if page.path == '' {
		panic('file path should never be empty, is bug')
	}
	return page.path
}

pub fn (page Page) path_dir_relative_get(mut publisher &Publisher) string {
	if page.path == '' {
		panic('file path should never be empty, is bug')
	}
	return os.dir(page.path).trim(" /")
}


pub fn (page Page) path_get(mut publisher &Publisher) string {
	if page.site_id > publisher.sites.len {
		panic('cannot find site: $page.site_id, not enough elements in list.')
	}
	if page.path == '' {
		panic('file path should never be empty, is bug. For page\n$page')
	}
	site_path := publisher.sites[page.site_id].path
	return os.join_path(site_path, page.path).replace("//","/")
}

// get the name of the page with or without site prefix, depending if page is in the site
pub fn (page Page) name_get(mut publisher &Publisher, site_id int) string {
	site := page.site_get(mut publisher) or { panic(err) }
	if site.id == site_id {
		return page.name
	} else {
		return '$site.name:$page.name'
	}
}
