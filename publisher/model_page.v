module publisher
import path as pathlib

// import path
import os

pub enum PageStatus {
	unknown
	ok
	error
}


[heap]
pub struct Page {	
pub:
	name string 		//received a name fix
	dirpath string		//path in site (without name)
	path Path
	site &Site [str: skip] //pointer to site
pub mut:
	state           PageStatus
	errors          []PageError
	pages_included  []&Page
	pages_linked    []&Page
	files_linked	[]&File
	content         string //is the processed content, not the original
	categories      []string
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

//only way how to get to a new page
pub (mut site Site) page_new(fpath string)?Page {
	mut p := pathlib.get_file(fpath)? //makes sure we have the right path
	if ! p.path.exists(){
		return error("cannot find page: $page for path: ${page.path}")
	}
	p.namefix()? //make sure its all lower case and name is proper
	mut p: = Page{
		name: p.name()
		dirpath: p.path_relative(site.path.path))
		path: p
		site: &site
	}
	if ! name.ends_with(".md"){
		return error("page $page needs to end with .md")
	}

	return p
}


// walk over categories, see if we can find the prefix which matches start of a category
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
		if cat !in page.categories {
			page.categories << cat
		}
	}
}


//get relative path with filename in the site
pub fn (page Page) path_relative() string {
	return os.join_path(page.dirpath,page.name)
}


