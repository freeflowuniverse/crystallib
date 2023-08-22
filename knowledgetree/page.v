module knowledgetree

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.markdowndocs { Link, Paragraph }
import freeflowuniverse.crystallib.texttools
import os

pub enum PageStatus {
	unknown
	ok
	error
}

[heap]
pub struct Page {
pub mut: // pointer to collection
	name           string // received a name fix
	collection     &Collection       [str: skip]
	path           pathlib.Path
	pathrel        string // relative path in the collection
	state          PageStatus
	pages_included []&Page           [str: skip]
	pages_linked   []&Page           [str: skip]
	files_linked   []&File           [str: skip]
	categories     []string
	doc            &markdowndocs.Doc [str: skip]
	readonly       bool
	changed        bool
}

fn (mut page Page) link_to_page_update(mut link Link) ! {
	assert link.cat == .page
	mut file_name := link.filename
	mut other_page := if page.collection.page_exists(file_name) {
		page.collection.page_get(file_name)!
	} else if page.collection.tree.page_exists(file_name) {
		page.collection.tree.page_get(file_name)!
	} else {
		page.collection.error(path: page.path, msg: 'link to unknown page: ${link.str()}', cat: .page_not_found)
		return
	}
	if ! (other_page in page.pages_linked) {
		page.pages_linked << other_page
	}
	linkcompare1 := link.description + link.url + link.filename + link.content
	imagelink_rel := pathlib.path_relative(page.path.path_dir(), other_page.path.path)!

	link.description = link.description
	link.path = os.dir(imagelink_rel)
	link.filename = os.base(imagelink_rel)
	link.content = link.wiki()
	linkcompare2 := link.description + link.url + link.filename + link.content
	if linkcompare1 != linkcompare2 {
		page.changed = true
	}
}

// update link on the page, find the link into the collection
fn (mut page Page) link_update(mut link Link) ! {
	// mut linkout := link
	mut file_name := link.filename
	page.collection.tree.logger.debug('get link ${link.content} with name:\'${file_name}\' for page: ${page.path.path}')

	// check if the file or image is there, if yes we can return, nothing to do
	mut file_search := true
	mut fileoj0 := File{
		collection: page.collection
	}
	mut fileobj := &fileoj0

	if link.cat == .image {
		if page.collection.image_exists(file_name) {
			file_search = false
			fileobj = page.collection.image_get(file_name)!
		}
	} else if link.cat == .file {
		if page.collection.file_exists(file_name) {
			file_search = false
			fileobj = page.collection.file_get(file_name)!
		}
	} else {
		panic('can\'t update link of type ${link.cat}')
	}

	if file_search {
		// if the collection is filled in then it means we need to copy the file here,
		// or the image is not found, then we need to try and find it somewhere else
		// we need to copy the image here
		fileobj = page.collection.tree.image_get(file_name) or {
			msg := "'${file_name}' not found for page:${page.path.path}, we looked over all collections."
			page.collection.error(path: page.path, msg: 'image ${msg}', cat: .image_not_found)
			return
		}
		// we found the image should copy to the collection now
		page.collection.tree.logger.debug('image or file found in other collection: ${fileobj}')
		page.collection.tree.logger.debug('${link}')
		mut dest := pathlib.get('${page.path.path_dir()}/img/${fileobj.path.name()}')
		pathlib.get_dir('${page.path.path_dir()}/img', true)! // make sure it exists
		page.collection.tree.logger.debug('*** COPY: ${fileobj.path.path} to ${dest.path}')
		if fileobj.path.path == dest.path {
			panic('source and destination is same when trying to fix link (copy).')
		}
		fileobj.path.copy(mut dest)!
		page.collection.image_new(mut dest)! // make sure collection knows about the new file
		fileobj.path = dest

		fileobj.path.check()
		if fileobj.path.is_link() {
			fileobj.path.unlink()! // make a real file, not a link
		}
	}

	// means we now found the file or image
	page.files_linked << fileobj
	linkcompare1 := link.description + link.url + link.filename + link.content
	imagelink_rel := pathlib.path_relative(page.path.path_dir(), fileobj.path.path)!

	link.description = link.description
	link.path = os.dir(imagelink_rel)
	link.filename = os.base(imagelink_rel)
	link.content = link.wiki()
	linkcompare2 := link.description + link.url + link.filename + link.content
	if linkcompare1 != linkcompare2 {
		page.changed = true
	}

	// link.link_update(mut paragraph, imagelink_rel, !page.readonly)!
	// if true || fileobj.path.path.contains('today_internet') {
	// 	println(link)
	// 	println(linkout)
	// 	// println(paragraph.wiki())
	// 	println(fileobj)
	// 	println(imagelink_rel)
	// 	panic('45jhg')
	// }
}

// checks if external link returns 404
// if so, prompts user to replace with new link
fn (mut page Page) fix_external_link(mut link Link) ! {
	// TODO: check if external links works
	// TODO: do error if not exist
}

fn (mut page Page) fix() ! {
	page.fix_links()!
	// TODO: do includes
	if page.changed {
		page.collection.tree.logger.debug('CHANGED: ${page.path}')
		page.save()!
		page.changed = false
	}
}

// walk over all links and fix them with location
fn (mut page Page) fix_links() ! {
	for x in 0..page.doc.items.len {
		if page.doc.items[x] is Paragraph {
			mut paragraph := page.doc.items[x] as Paragraph
			for y in 0..paragraph.items.len {
				if paragraph.items[y] is Link {
					mut item_link := paragraph.items[y] as Link
					if item_link.filename == 'threefold_cloud.md' {
						print("${item_link}")
					}
					if item_link.isexternal {
						page.fix_external_link(mut item_link)!
					} else if item_link.cat == .image || item_link.cat == .file {
						// this will change the link			
						page.link_update(mut item_link)!
					} else if item_link.cat == .page {
						page.link_to_page_update(mut item_link)!
					}
					paragraph.items[y] = item_link
				}
			}
			page.doc.items[x] = paragraph
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
		if line.trim_space().starts_with('!!include ') {
			page_name_include = texttools.name_fix_no_ext(line.all_after_first('!!include ')).trim_space()
		}

		// TODO: need other type of include macro format !!!include ...
		if page_name_include != '' {
			//* means we dereference, we have a copy so we can change
			mut page_include := *page.collection.page_get(page_name_include) or {
				msg := "include:'${page_name_include}' not found for page:${page.path.path}"
				page.collection.error(path: page.path, msg: 'include ${msg}', cat: .page_not_found)
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
			// panic('implement include')
			if page_include.files_linked.len > 0 {
				page_include.fix()!
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
	mut out := page.doc.wiki()
	out = page.process_macro_include(out)!
	return out
}

[params]
pub struct PageSaveArgs {
pub mut:
	dest string
}

// save the page on the requested dest
// make sure the macro's are being executed
pub fn (mut page Page) save(args_ PageSaveArgs) ! {
	mut args := args_
	if args.dest == '' {
		args.dest = page.path.path
	}
	page.fix_links()! // always need to make sure that the links are now clean
	mut out := page.process_macros()!
	// out = page.doc.wiki()
	mut p := pathlib.get_file(args.dest, true)!
	p.write(out)!

	// mutate page to save updated doc
	updated_doc := markdowndocs.new(path: p.path) or { panic('cannot parse,${err}') }
	page.doc = &updated_doc
}
