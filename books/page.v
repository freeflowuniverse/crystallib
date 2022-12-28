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
	// empty just to fill in on next
	mut fileobj := &File{
		site: page.site
	}

	// if its not an image, we can only check if it exists, if not return and report error
	if link.cat == .file {
		if link.site != '' {
			return error('do not support link.site:filename for files.')
		}
		if !page.site.file_exists(file_name) {
			msg := "'${file_name}' not found for page:${page.path.path}"
			page.site.error(path: page.path, msg: 'file ${msg}', cat: .file_not_found)
			return
		}
		fileobj = page.site.file_get(file_name) or { panic(err) } // should never get here
	} else {
		if link.site != '' || !page.site.image_exists(file_name) {
			println(" *** image needs to be in other site, lets check: '${file_name}'")
			file_name2 := page.site.sites.image_name_find(file_name)!
			if file_name2 == '' {
				// we could not find the filename not even in other sites
				println("     * we couldnt find image: '${file_name}'")
				msg := "'${file_name}' not found for page:${page.path.path}"
				page.site.error(path: page.path, msg: 'image ${msg}', cat: .image_not_found)
				return
			}
			// we found the image should copy to the site now
			file_name = file_name2
			fileobj = page.site.image_get(file_name) or { panic(err) } // should never get here
			println("     * image found: '${fileobj}'")
			mut dest := pathlib.get('${page.path.path_dir()}/img/${fileobj.path.name()}')
			pathlib.get_dir('${page.path.path_dir()}/img', true)! // make sure it exists
			println(' *** COPY: ${fileobj.path.path} to ${dest.path}')
			fileobj.path.copy(mut dest)!
			page.site.image_new(mut dest)! // make sure site knows about the new file
			fileobj.path = dest
		} else {
			fileobj = page.site.image_get(file_name) or { panic(err) } // should never get here
		}
	}
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
	if link.filename.contains('crisis_waves') {
		println(link)
		println(page)
		panic('Sdsd')
	}
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
