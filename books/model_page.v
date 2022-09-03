module books
import path as pathlib
import markdowndocs

pub enum PageStatus {
	unknown
	ok
	error
}

[heap]
pub struct Page {	
pub:
	name string 		//received a name fix
	site &Site [str: skip] //pointer to site
pub mut:
	path pathlib.Path
	pathrel string
	state           PageStatus
	pages_included  []&Page
	pages_linked    []&Page
	files_linked	[]&File
	categories      []string
	doc				markdowndocs.Doc
}

//only way how to get to a new page
pub fn (mut site Site) page_new(fpath string)?Page {
	mut p := pathlib.get_file(fpath,false)? //makes sure we have the right path
	if ! p.exists(){
		return error("cannot find page with path ${fpath}")
	}
	p.namefix()? //make sure its all lower case and name is proper
	mut page  := Page{
		name: p.name()
		path: p
		pathrel: p.path_relative(site.path.path)
		site: &site
	}
	if ! page.name.ends_with(".md"){
		return error("page $page needs to end with .md")
	}

	//parse the markdown of the page
	mut parser := markdowndocs.get(p.path) or { panic('cannot parse,$err') }
	page.doc = parser.doc

	return page
}

