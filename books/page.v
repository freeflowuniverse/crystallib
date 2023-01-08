module books

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.markdowndocs { Link }
import freeflowuniverse.crystallib.texttools

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
	readonly       bool
}

// //relative path in the site
// fn (mut page Page) path_in_site(mut link Link) ! {

// 	imagelink_rel := pathlib.path_relative(page.site.path.path, fileobj.path.path)!

// 	return page.site

// }

fn (mut page Page) fix_link(mut link Link) ! {
	mut file_name := link.filename
	$if debug {
		println(' - fix link ${link.original} with name:${file_name} for page: ${page.path.path}')
	}

	// check if the file or image is there, if yes we can return, nothing to do
	if link.cat == .image {
		if page.site.image_exists(file_name){return}
	}else{
		if page.site.file_exists(file_name){return}
	}

	//if the site is filled in then it means we need to copy the file here, 
	//or the image is not found, then we need to try and find it somewhere else
	//we need to copy the image here
	mut fileobj:=page.site.sites.image_file_find_over_sites(file_name) or {
		msg := "'${file_name}' not found for page:${page.path.path}, we looked over all sites."
		println("    * $msg")
		page.site.error(path: page.path, msg: 'image ${msg}', cat: .image_not_found)
		return
	}
	// we found the image should copy to the site now
	println("     * image or file found in other site: '${fileobj}'")
	println(link)
	mut dest := pathlib.get('${page.path.path_dir()}/img/${fileobj.path.name()}')
	pathlib.get_dir('${page.path.path_dir()}/img', true)! // make sure it exists
	println(' *** COPY: ${fileobj.path.path} to ${dest.path}')
	if fileobj.path.path == dest.path{
		println(fileobj)
		panic("source and destination is same when trying to fix link.")
	}
	fileobj.path.copy(mut dest)!
	page.site.image_new(mut dest)! // make sure site knows about the new file
	fileobj.path = dest

	fileobj.path.check()
	if fileobj.path.is_link() {
		fileobj.path.unlink()! // make a real file, not a link
	}

	// means we now found the file or image
	page.files_linked << fileobj

	imagelink_rel := pathlib.path_relative(page.path.path_dir(), fileobj.path.path)!
	link.description = ''
	// last arg is if we need to save when link changed, only change when page is not readonly
	link.link_update(imagelink_rel, !page.readonly)!
}

// checks if external link returns 404
// if so, prompts user to replace with new link
fn (mut page Page) fix_external_link(mut link Link) ! {
	// TODO: check if external links works
	// TODO: do error if not exist
}

fn (mut page Page) fix() ! {
	page.fix_links()!
}

// walk over all links and fix them with location
fn (mut page Page) fix_links() ! {
	// mut changed := false

	for mut item in page.doc.items.filter(it is markdowndocs.Paragraph) {
		if mut item is markdowndocs.Paragraph {
			for mut link in item.links {
				if link.isexternal {
					page.fix_external_link(mut link)!
				} else if link.cat == .image || link.cat == .file {
					page.fix_link(mut link)!
				}
			}
		}
	}
}

// will execute on 1 specific macro = include
fn (mut page Page) process_macro_include(content string) !string {
	mut result := []string{}
	for mut line in content.split_into_lines() {
		mut page_name_include := ''
		if line.trim_space().starts_with('{{#include') {
			page_name_include = texttools.name_fix_no_ext(line.all_after_first('#include').all_before('}}').trim_space())
		}
		// TODO: need other type of include macro format !!!include ...
		if page_name_include != '' {
			//* means we dereference, we have a copy so we can change
			mut page_include := *page.site.page_get(page_name_include) or {
				msg := "include:'${page_name_include}' not found for page:${page.path.path}"
				page.site.error(path: page.path, msg: 'include ${msg}', cat: .page_not_found)
				line = '> ERROR: ${msg}'
				continue
			}
			page_include.readonly = true // we should not save this file
			page_include.name = 'DONOTSAVE'
			page_include.path = page.path // we need to operate in path from where we include from

			line = ''
			for line_include in page_include.doc.content.split_into_lines() {
				result << line_include
			}
			if page_include.files_linked.len > 0 {
				page_include.fix()!
				println(page_include)
				println(page_include.files_linked)
				panic('sdsds')
			}
		}
		if line != '' {
			result << line
		}
	}
	return result.join('\n')
}

// will process the macro's and return string
fn (mut page Page) process_macros() !string {
	mut out := page.doc.content
	out = page.process_macro_include(out)!
	return out
}

// save the page on the requested dest
// make sure the macro's are being executed
pub fn (mut page Page) save(dest0 string) ! {
	mut dest := dest0
	if dest == '' {
		dest = page.path.path
	}
	out := page.process_macros()!
	mut p := pathlib.get_file(dest, true)!
	p.write(out)!
}
