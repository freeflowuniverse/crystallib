module doctree

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.markdownparser.elements { Action, Doc, Include, Link, Paragraph }
import freeflowuniverse.crystallib.data.markdownparser
import os

pub enum PageStatus {
	unknown
	ok
	error
}

@[heap]
pub struct Page {
pub mut:
	name           string // received a name fix
	path           pathlib.Path
	pathrel        string // relative path in the playbook
	state          PageStatus
	pages_included []&Page      @[str: skip]
	pages_linked   []&Page      @[str: skip]
	files_linked   []&File      @[str: skip]
	categories     []string
	doc            ?Doc         @[str: skip]
	readonly       bool
	changed        bool
	tree_name      string
	tree           &Tree        @[str: skip]
	playbook_name  string
}

fn (mut page Page) link_to_page_update(mut link Link) ! {
	if link.cat != .page {
		panic('link should be of type page not ${link.cat}')
	}
	mut file_name := link.filename

	mut other_page := &Page{
		tree: page.tree
	}

	mut playbook := page.tree.playbooks[page.playbook_name] or {
		return error("could not find playbook:'${page.playbook_name}' in tree: ${page.tree_name}")
	}

	if file_name in playbook.pages {
		other_page = playbook.pages[file_name] or { panic('bug') }
	} else if page.tree.page_exists(file_name) {
		other_page = page.tree.page_get(file_name)!
	} else {
		playbook.error(
			path: page.path
			msg: 'link to unknown page: ${link.str()}'
			cat: .page_not_found
		)
		return
	}
	page.pages_linked << other_page

	linkcompare1 := link.description + link.url + link.filename + link.content
	imagelink_rel := pathlib.path_relative(page.path.path_dir(), other_page.path.path)!

	link.description = link.description
	link.path = os.dir(imagelink_rel)
	link.filename = os.base(imagelink_rel)
	link.content = link.markdown()
	linkcompare2 := link.description + link.url + link.filename + link.content
	if linkcompare1 != linkcompare2 {
		page.changed = true
	}
}

// update link on the page, find the link into the playbook
fn (mut page Page) link_update(mut link Link) ! {
	// mut linkout := link
	mut file_name := link.filename
	println('get link ${link.content} with name:\'${file_name}\' for page: ${page.path.path}')
	name_without_ext := file_name.all_before('.')

	mut playbook := page.tree.playbooks[page.playbook_name] or {
		return error("2could not find playbook:'${page.playbook_name}' in tree: ${page.tree_name}")
	}

	// check if the file or image is there, if yes we can return, nothing to do
	mut file_search := true
	// fileobj := File{playbook: }

	mut fileobj := &File{
		playbook: playbook
	}
	if link.cat == .image {
		if playbook.image_exists(name_without_ext) {
			file_search = false
			fileobj = playbook.image_get(name_without_ext)!
		} else {
			msg := "'${name_without_ext}' not found for page:${page.path.path}, we looked over all playbooks."
			playbook.error(path: page.path, msg: 'image ${msg}', cat: .image_not_found)
		}
	} else if link.cat == .file {
		if playbook.file_exists(name_without_ext) {
			file_search = false
			fileobj = playbook.file_get(name_without_ext)!
		} else {
			playbook.error(path: page.path, msg: 'file not found', cat: .file_not_found)
		}
	} else {
		panic('link should be of type image or file, not ${link.cat}')
	}

	if file_search {
		// if the playbook is filled in then it means we need to copy the file here,
		// or the image is not found, then we need to try and find it somewhere else
		// we need to copy the image here
		fileobj = page.tree.image_get(name_without_ext) or {
			msg := "'${name_without_ext}' not found for page:${page.path.path}, we looked over all playbooks."
			playbook.error(path: page.path, msg: 'image ${msg}', cat: .image_not_found)
			return
		}
		// we found the image should copy to the playbook now
		$if debug {
			println('image or file found in other playbook: ${fileobj}')
		}
		$if debug {
			println('${link}')
		}
		mut dest := pathlib.get('${page.path.path_dir()}/img/${fileobj.path.name()}')
		pathlib.get_dir(path: '${page.path.path_dir()}/img', create: true)! // make sure it exists
		$if debug {
			println('*** COPY: ${fileobj.path.path} to ${dest.path}')
		}
		if fileobj.path.path == dest.path {
			panic('source and destination is same when trying to fix link (copy).')
		}
		fileobj.path.copy(dest: dest.path)!
		playbook.image_new(mut dest)! // make sure playbook knows about the new file
		fileobj.path = dest

		fileobj.path.check()
		if fileobj.path.is_link() {
			fileobj.path.unlink()! // make a real file, not a link
		}
	}

	// hack around
	fileobj_copy := &(*fileobj)
	// means we now found the file or image
	page.files_linked << fileobj_copy
	linkcompare1 := link.description + link.url + link.filename + link.content
	imagelink_rel := pathlib.path_relative(page.path.path_dir(), fileobj.path.path)!

	link.description = link.description
	link.path = os.dir(imagelink_rel)
	link.filename = os.base(imagelink_rel)
	link.content = link.markdown()
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
		$if debug {
			println('CHANGED: ${page.path}')
		}
		page.save()!
		page.changed = false
	}
}

// walk over all links and fix them with location
fn (mut page Page) fix_links() ! {
	mut doc := page.doc or { return error('no doc yet on page') }
	for x in 0 .. doc.children.len {
		mut paragraph := doc.children[x]
		if mut paragraph is Paragraph {
			for y in 0 .. paragraph.children.len {
				mut item_link := paragraph.children[y]
				if mut item_link is Link {
					if item_link.filename == 'threefold_cloud.md' {
						print('${item_link}')
					}
					if item_link.isexternal {
						page.fix_external_link(mut item_link)!
					} else if item_link.cat == .image || item_link.cat == .file {
						// this will change the link			
						page.link_update(mut item_link)!
					} else if item_link.cat == .page {
						page.link_to_page_update(mut item_link)!
					}
					paragraph.children[y] = item_link
				}
			}
			doc.children[x] = paragraph
		}
	}
}

// include receives a map of pagess to include indexed to
// the position of the include statement the page is supposed to replace
fn (mut page Page) include(pages_to_include map[int]Page) ! {
	// now we need to remove the links and replace them with the items from the doc of the page to insert
	mut doc := page.doc or { return error('no doc on including page') }
	mut offset := 0
	for x, page_to_include in pages_to_include {
		docinclude := page_to_include.doc or { panic('no doc on include page') }
		doc.children.delete(x + offset)
		doc.children.insert(x + offset, docinclude.children)
		offset += doc.children.len - 1
	}
	page.doc = doc
}

// process_includes recursively processes the include actiona in a page
// and includes pages into the markdown doc if found in tree
fn (mut page Page) process_includes(mut include_tree []string) ! {
	mut playbook := page.tree.playbook_get(page.playbook_name) or {
		return error("1could not find playbook:'${page.playbook_name}' in tree: ${page.tree_name}")
	}
	mut doc := page.doc or { return error('no doc yet on page') }
	// check for circular imports
	if page.name in include_tree {
		history := include_tree.join(' -> ')
		playbook.error(
			path: page.path
			msg: 'Found a circular include: ${history} in '
			cat: .circular_import
		)
		return
	}
	include_tree << page.name

	// find the files to import
	mut included_pages := map[int]&Page{}
	for x in 0 .. doc.children.len {
		mut include := doc.children[x]
		if mut include is Include {
			$if debug {
				println('Including page ${include.content} into ${page.path.path}')
			}
			mut page_to_include := page.tree.page_get(include.content) or {
				println('debugzo')
				msg := "include:'${include.content}' not found for page:${page.path.path}"
				page.tree.playbooks[playbook.name].error(
					path: page.path
					msg: 'include ${msg}'
					cat: .page_not_found
				)
				continue
			}
			$if debug {
				println('Found page in playbook ${page_to_include.playbook_name}')
			}
			page_to_include.process_includes(mut include_tree)!
			included_pages[x] = page_to_include
		}
	}

	println(page.tree.playbooks[playbook.name])

	// now we need to remove the links and replace them with the items from the doc of the page to insert
	mut offset := 0
	for x, page_to_include in included_pages {
		docinclude := page_to_include.doc or { panic('no doc on include page') }
		doc.children.delete(x + offset)
		doc.children.insert(x + offset, docinclude.children)
		offset += doc.children.len - 1
	}
	page.doc = doc
}

// will process the macro's and return string
fn (mut page Page) process_macros() ! {
	page.tree.logger.info('Processing macros in page ${page.name}')
	mut doc := page.doc or { return error('no doc yet on page') }
	for x in 0 .. doc.children.len {
		mut macro := doc.children[x]
		if mut macro is Action {
			page.tree.logger.info('Process macro: ${macro.action.name} into page: ${page.name}')

			// TODO: need to use other way how to do macros (despiegk)

			// for mut mp in page.tree.macroprocessors {
			// 	res := mp.process('!!${macro.content}')!

			// 	mut para := Paragraph{
			// 		content: res.result
			// 	}
			// 	// para.process()!
			// 	doc.children.delete(x)
			// 	doc.children.insert(x, elements.Element(para))
			// 	if res.state == .stop {
			// 		break
			// 	}
			// }
		}
	}
	page.doc = doc
}

@[params]
pub struct PageSaveArgs {
pub mut:
	dest string
}

// save the page on the requested dest
// make sure the macro's are being executed
pub fn (mut page Page) process() ! {
	page.process_macros()!
	// page.fix_links()! // always need to make sure that the links are now clean
}

// save the page on the requested dest
// make sure the macro's are being executed
pub fn (mut page Page) export(args_ PageSaveArgs) ! {
	mut args := args_
	if args.dest == '' {
		args.dest = page.path.path
	}
	// QUESTION: okay convention?
	out := page.doc or { panic('this should never happen') }.markdown()
	mut p := pathlib.get_file(path: args.dest, create: true)!
	p.write(out)!

	// mutate page to save updated doc
	updated_doc := markdownparser.new(path: p.path) or { panic('cannot parse,${err}') }
	page.doc = updated_doc
}

// save the page on the requested dest
// make sure the macro's are being executed
pub fn (mut page Page) save(args_ PageSaveArgs) ! {
	mut args := args_
	if args.dest == '' {
		args.dest = page.path.path
	}
	page.process_macros()!
	// page.fix_links()! // always need to make sure that the links are now clean
	// QUESTION: okay convention?
	out := page.doc or { panic('this should never happen') }.markdown()
	mut p := pathlib.get_file(path: args.dest, check: false)!
	p.write(out)!

	// mutate page to save updated doc
	updated_doc := markdownparser.new(path: p.path) or { panic('cannot parse,${err}') }
	page.doc = updated_doc
}
