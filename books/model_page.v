module books

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.markdowndocs { Link }
import os

pub enum PageStatus {
	unknown
	ok
	error
}

[heap]
pub struct Page {
pub mut: // pointer to site
	name           string // received a name fix
	site           &Site            [str: skip]
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

fn (mut page Page) fix_img_location(mut link Link) ? bool {
	println('relocating img $page,  $link')
	img_name := link.filename.all_before_last('.').trim_right('_').to_lower()
	if img_name in page.site.files {
		originalfilename := link.filename
		image := page.site.files[img_name]

	}
	return false
}

fn (mut page Page) fix_img_link(mut link Link) ? {
	name := link.filename.all_before_last('.').trim_right('_').to_lower()
	$if debug {println('fixing image: $name  $link')}
	if name in page.site.files {
		originalfilename := link.filename
		image := page.site.files[name]

		mut source := page.pathrel.all_before_last('/') // this is the relative path of where the page is in relation to site root
		mut imagelink_rel := pathlib.path_relative(source, image.pathrel)?

		// updates the link to the image correctly
		if link.link_update(imagelink_rel) {
			// SHORTCUT
			page.doc.content = page.doc.content.replace(originalfilename, link.filename)
			$if debug {println('change: $originalfilename -> $link.filename')}
			page.doc.save()?
		}
	} else {
		page.site.error(
			path: page.path
			msg: 'could not find image: $name in site:$page.site.name'
			cat: .file_not_found
		)
	}
}

fn (mut page Page) fix_file_link(mut link Link) ? {
	name := link.filename.all_before_last('.').trim_right('_').to_lower()
	if name in page.site.pages {
		originalfilename := link.filename
		original_link := '$link.path/$link.filename'
		page_linked := page.site.pages[name]
		mut source := page.pathrel.all_before_last('/') // this is the relative path of where the page is in relation to site root
		mut filelink_rel := pathlib.path_relative(source, page_linked.pathrel)?
		if link.link_update(filelink_rel) {
			if original_link.trim_space() != filelink_rel.trim_space() {
				page.doc.content = page.doc.content.replace(originalfilename, link.filename)
				println('change: $original_link -> $filelink_rel')
			}
			page.doc.save()?
			//? There use to be panic here, does this work as it's supposed to?
			// panic('to do link update')
		}
	} else {
		page.site.error(
			path: page.path
			msg: 'could not find page: $name in site:$page.site.name'
			cat: .page_not_found
		)
	}
}

// checks if external link returns 404
// if so, prompts user to replace with new link
fn (mut page Page) fix_external_link(mut link Link) ? {
	// TODO: check if external links works
	// TODO: prompt user for new link
}

fn (mut page Page) fix() ? {
	// page.links_fix()?
}

// walk over all links and fix them with location
// TODO: inquire about use of filter below
fn (mut page Page) links_fix() ? {
	mut changed := false
	for mut item in page.doc.items.filter(it is markdowndocs.Paragraph) {
		if mut item is markdowndocs.Paragraph { //? interestingly necessary despite filter
			for mut link in item.links {
				if link.isexternal {
					page.fix_external_link(mut link)?
				} else if link.cat == .image {
					page.fix_img_location(mut link)?
					page.fix_img_link(mut link)?
				} else if link.cat == .file {
					page.fix_file_link(mut link)?
				}
			}
		}
	}
}
