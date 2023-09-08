module knowledgetree

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.markdowndocs { Action, Include, Link, Paragraph }
import os

pub enum PageStatus {
	unknown
	ok
	error
}

[heap]
pub struct Page {
pub mut: // pointer to collection
	name            string // received a name fix
	path            pathlib.Path
	pathrel         string // relative path in the collection
	state           PageStatus
	pages_included  []&Page           [str: skip]
	pages_linked    []&Page           [str: skip]
	files_linked    []&File           [str: skip]
	categories      []string
	doc             ?markdowndocs.Doc [str: skip]
	readonly        bool
	changed         bool
	tree_name       string
	collection_name string
}

fn (mut page Page) link_to_page_update(mut link Link) ! {
	if link.cat != .page {
		panic('link should be of type page not ${link.cat}')
	}
	mut file_name := link.filename

	mut other_page := Page{}

	lock knowledgetrees {
		mut tree := knowledgetrees[page.tree_name] or {
			return error('could not find treename: ${page.tree_name}')
		}
		mut collection := tree.collections[page.collection_name] or {
			return error("3could not find collection:'${page.collection_name}' in tree: ${page.tree_name}")
		}

		if file_name in collection.pages {
			other_page = collection.pages[file_name] or { panic('bug') }
		} else if tree.page_exists(file_name) {
			other_page = tree.page_get(file_name)!
		} else {
			collection.error(
				path: page.path
				msg: 'link to unknown page: ${link.str()}'
				cat: .page_not_found
			)
			return
		}
		page.pages_linked << &other_page
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
	println('get link ${link.content} with name:\'${file_name}\' for page: ${page.path.path}')

	lock knowledgetrees {
		mut tree := knowledgetrees[page.tree_name] or {
			return error('could not find treename: ${page.tree_name}')
		}
		println('debus: ${tree}')
		mut collection := tree.collections[page.collection_name] or {
			return error("2could not find collection:'${page.collection_name}' in tree: ${page.tree_name}")
		}

		// check if the file or image is there, if yes we can return, nothing to do
		mut file_search := true
		mut fileobj := File{}

		if link.cat == .image {
			if collection.image_exists(file_name) {
				file_search = false
				fileobj = collection.image_get(file_name)!
			}
		} else if link.cat == .file {
			if collection.file_exists(file_name) {
				file_search = false
				fileobj = collection.file_get(file_name)!
			}
		} else {
			panic('link should be of type image or file, not ${link.cat}')
		}

		if file_search {
			// if the collection is filled in then it means we need to copy the file here,
			// or the image is not found, then we need to try and find it somewhere else
			// we need to copy the image here
			fileobj = tree.image_get(file_name) or {
				msg := "'${file_name}' not found for page:${page.path.path}, we looked over all collections."
				collection.error(path: page.path, msg: 'image ${msg}', cat: .image_not_found)
				return
			}
			// we found the image should copy to the collection now
			$if debug {
				println('image or file found in other collection: ${fileobj}')
			}
			$if debug {
				println('${link}')
			}
			mut dest := pathlib.get('${page.path.path_dir()}/img/${fileobj.path.name()}')
			pathlib.get_dir('${page.path.path_dir()}/img', true)! // make sure it exists
			$if debug {
				println('*** COPY: ${fileobj.path.path} to ${dest.path}')
			}
			if fileobj.path.path == dest.path {
				panic('source and destination is same when trying to fix link (copy).')
			}
			fileobj.path.copy(mut dest)!
			collection.image_new(mut dest)! // make sure collection knows about the new file
			fileobj.path = dest

			fileobj.path.check()
			if fileobj.path.is_link() {
				fileobj.path.unlink()! // make a real file, not a link
			}
		}

		// means we now found the file or image
		page.files_linked << &fileobj
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
	for x in 0 .. doc.items.len {
		if doc.items[x] is Paragraph {
			mut paragraph := doc.items[x] as Paragraph
			for y in 0 .. paragraph.items.len {
				if paragraph.items[y] is Link {
					mut item_link := paragraph.items[y] as Link
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
					paragraph.items[y] = item_link
				}
			}
			doc.items[x] = paragraph
		}
	}
}

fn (mut page Page) process_includes(mut include_tree []string) ! {
	rlock knowledgetrees {
		mut tree := knowledgetrees[page.tree_name] or {
			return error('could not find treename: ${page.tree_name}')
		}
		mut collection := tree.collections[page.collection_name] or {
			return error("1could not find collection:'${page.collection_name}' in tree: ${page.tree_name}")
		}
		mut doc := page.doc or { return error('no doc yet on page') }
		// check for circular imports
		if page.name in include_tree {
			history := include_tree.join(' -> ')
			collection.error(
				path: page.path
				msg: 'Found a circular include: ${history} in '
				cat: .circular_import
			)
			return
		}
		include_tree << page.name

		// find the files to import
		mut included_pages := map[int]&Page{}
		for x in 0 .. doc.items.len {
			if doc.items[x] is Include {
				include := doc.items[x] as Include
				$if debug {
					println('Including page ${include.content} into ${page.path.path}')
				}
				mut page_to_include := *collection.page_get(include.content) or {
					msg := "include:'${include.content}' not found for page:${page.path.path}"
					collection.error(path: page.path, msg: 'include ${msg}', cat: .page_not_found)
					continue
				}
				$if debug {
					println('Found page in collection ${page_to_include.collection_name}')
				}
				page_to_include.process_includes(mut include_tree)!
				included_pages[x] = &page_to_include
			}
		}

		// now we need to remove the links and replace them with the items from the doc of the page to insert
		mut offset := 0
		for x, page_to_include in included_pages {
			docinclude := page_to_include.doc or { panic('no doc on include page') }
			doc.items.delete(x + offset)
			doc.items.insert(x + offset, docinclude.items)
			offset += doc.items.len - 1
		}
	}
}

// will process the macro's and return string
fn (mut page Page) process_macros() ! {
	mut doc := page.doc or { return error('no doc yet on page') }
	for x in 0 .. doc.items.len {
		println('item: ${doc.items[x]}')
		if doc.items[x] is Action {
			macro := doc.items[x] as Action
			// println(doc.items[x])
			println('Process macro ${macro.content} into ${page.path.path}')
			mut out := ''

			// QUESTION: is this implementation ok?
			mut tree := Tree{}
			lock {
				tree = knowledgetrees[page.tree_name]
			}
			// println('check: ${tree}')

			for mut mp in tree.macroprocessors {
				res := mp.process('!!${macro.content}')!
				if res.error == '' {
					out += res.result + '\n'
				} else {
					out += '>> ERROR:\n${res.error}\n'
				}
				mut para := Paragraph{
					content: res.result
				}
				para.process()!
				doc.items.delete(x)
				doc.items.insert(x, para)
				if res.state == .stop {
					break
				}
			}
		}
	}
	// QUESTION: is this best practice? alternatives are also difficult and hacky
	page.doc = doc
}

[params]
pub struct PageSaveArgs {
pub mut:
	dest string
}

// save the page on the requested dest
// make sure the macro's are being executed
pub fn (mut page Page) save(args_ PageSaveArgs) ! {
	mut doc := page.doc or { return error('no doc yet on page') }
	mut args := args_
	if args.dest == '' {
		args.dest = page.path.path
	}
	mut include_tree := []string{}
	page.process_includes(mut include_tree)!
	page.process_macros()!
	page.fix_links()! // always need to make sure that the links are now clean
	// QUESTION: okay convention?
	out := page.doc or { panic('this should never happen') }.wiki()
	mut p := pathlib.get_file(args.dest, true)!
	p.write(out)!

	// mutate page to save updated doc
	updated_doc := markdowndocs.new(path: p.path) or { panic('cannot parse,${err}') }
	page.doc = updated_doc
}
