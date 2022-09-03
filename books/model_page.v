module books

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.markdowndocs

pub enum PageStatus {
	unknown
	ok
	error
}

[heap]
pub struct Page {
pub:
	site &Site [str: skip]
pub mut: // pointer to site
	name           string // received a name fix
	path           pathlib.Path
	pathrel        string
	state          PageStatus
	pages_included []&Page
	pages_linked   []&Page
	files_linked   []&File
	categories     []string
	doc            markdowndocs.Doc
}

// only way how to get to a new page
pub fn (mut site Site) page_new(mut p pathlib.Path) ?Page {
	if !p.exists() {
		return error('cannot find page with path $p.path')
	}
	p.namefix()? // make sure its all lower case and name is proper
	mut page := Page{
		path: p
		site: &site
	}
	if !page.name.ends_with('.md') {
		return error('page $page needs to end with .md')
	}

	// parse the markdown of the page
	mut parser := markdowndocs.get(p.path) or { panic('cannot parse,$err') }
	page.doc = parser.doc

	return page
}

fn (mut page Page) init() {
	page.name = page.path.name_no_ext()
	page.pathrel = page.path.path_relative(page.site.path.path)
}
