module books

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.markdowndocs
import os

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
	pages_included []&Page          [str: skip]
	pages_linked   []&Page          [str: skip]
	files_linked   []&File          [str: skip]
	categories     []string
	doc            markdowndocs.Doc [str: skip]
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
	if !page.path.path.ends_with('.md') {
		return error('page $page needs to end with .md')
	}
	// println(" ---------- $page.path.path")
	// parse the markdown of the page
	mut parser := markdowndocs.get(p.path) or { panic('cannot parse,$err') }
	page.doc = parser.doc
	page.name = p.name_no_ext()
	page.pathrel = p.path_relative(site.path.path).trim('/')
	site.pages[page.name] = page

	return page
}

fn (mut page Page) fix() ? {
	page.links_fix()?
}

// walk over all links and fix them with location
fn (mut page Page) links_fix() ? {
	mut changed := false
	for mut item in page.doc.items {
		if mut item is markdowndocs.Paragraph {
			for mut link in item.links {
				name := link.filename.all_before_last('.').trim_right('_').to_lower()
				originalfilename:=link.filename
				if link.cat == .image {
					if name in page.site.files {
						image := page.site.files[name]

						mut source := page.pathrel.all_before_last('/') // this is the relative path of where the page is in relation to site root
						mut imagelink_rel := pathlib.path_relative(source, image.pathrel)?

						if link.link_update(imagelink_rel) {
							changed = true
						}
						if changed{
							page.doc.content=page.doc.content.replace(originalfilename,link.filename)
							println(page.doc.content)
						}
						// println(changed)
						// println(link)
						// println(image)
						
						panic('sss')
					} else {
						panic('ssssse:$name')
					}
				}
			}
		}
	}
}
