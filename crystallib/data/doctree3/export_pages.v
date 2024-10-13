module doctree3

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.doctree3.collection
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.texttools.regext
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.data.markdownparser.elements

@[params]
pub struct ExportPagesArgs {
pub mut:
	dir_src        pathlib.Path
	keep_structure bool // wether the structure of the src collection will be preserved or not
	replacer       ?regext.ReplaceInstructions
}

pub fn (mut t Tree) export_collection_pages(mut c collection.Collection, args ExportPagesArgs) ! {
	for _, mut page in c.pages {
		dest := if args.keep_structure {
			relpath := page.path.path.trim_string_left(c.path.path)
			'${args.dir_src.path}/${relpath}'
		} else {
			'${args.dir_src.path}/${page.name}.md'
		}

		t.export_page(mut page, dest: dest, replacer: args.replacer)!
	}
}

@[params]
pub struct PageExportArgs {
pub mut:
	dest     string                      @[required]
	replacer ?regext.ReplaceInstructions
}

// save the page on the requested dest
// make sure the macro's are being executed
fn (mut t Tree) export_page(mut page collection.Page, args_ PageExportArgs) ! {
	mut args := args_

	mut doc := markdownparser.new(content: page.doc()!.markdown()!)!
	page.doc_ = &doc

	page.doc_process()!

	mut p := pathlib.get_file(path: args.dest, create: true)!
	dirpath := p.parent()!

	t.process_page_links(mut page, dest: dirpath.path)!
	mut mydoc := page.doc()!

	mut markdown := mydoc.markdown()!
	if args.replacer != none {
		markdown = args.replacer or { panic('bug') }.replace(text: markdown)!
	}
	p.write(markdown)!
}

@[params]
struct DocArgs {
mut:
	// heal_source bool
	dest string   @[required] // if we want to relocate images or files or pages for links, is the directory of the collection at destination !!!
	done []string
}

fn (mut t Tree) process_page_links(mut page collection.Page, args_ DocArgs) ! {
	mut args := args_
	mut mydoc := page.doc()!

	mut col := t.collection_get(page.collection_name)!

	args.done << page.name
	// console.print_debug('++++ process links doc: ${collection.name}:${page.name} -> ${args.dest} ')

	// find the links, and for each link check if collection is same, is not need to copy
	for mut element in mydoc.children_recursive() {
		if mut element is elements.Link {
			// console.print_debug(element)
			mut name := texttools.name_fix_keepext(element.filename)
			mut site := texttools.name_fix(element.site)
			if site == '' {
				site = col.name
			}
			pointername := '${site}:${name}'

			mut collection_path := '.'
			if element.cat == .image {
				// console.print_debug('POINTER IMAGE: ' + pointername)
				mut linkimage := t.image_get(pointername) or {
					col.error(
						path: page.path
						msg: 'image not found: ${pointername}'
						cat: .image_not_found
					)
					element.state = .linkprocessed
					continue
				}

				if linkimage.collection.name != page.collection_name {
					collection_path = '../${linkimage.collection.name}'
				}

				mut out := ''
				if element.extra.trim_space() == '' {
					out = '![${element.description}](${collection_path}/img/${linkimage.file_name()})'
				} else {
					out = '![${element.description}](${collection_path}/img/${linkimage.file_name()} ${element.extra})'
				}

				mydoc.content_set(element.id, out)
				element.processed = false
				element.process()!

				element.state = .linkprocessed
			} else if element.cat == .page {
				// console.print_debug('POINTER PAGE: ' + pointername)
				mut linkpage := t.page_get(pointername) or {
					col.error(
						path: page.path
						msg: 'page not found: ${pointername}'
						cat: .page_not_found
					)
					element.state = .linkprocessed
					continue
				}

				if linkpage.collection_name != page.collection_name {
					collection_path = '../${linkpage.collection_name}'
				}
				// this is to remember the pages which are linked
				if pointername !in mydoc.linked_pages {
					mydoc.linked_pages << pointername
				}

				mut out := '[${element.description}](${collection_path}/${linkpage.name}.md)'

				mydoc.content_set(element.id, out)
				element.state = .linkprocessed
				element.processed = false
				element.process()!
			}
		}
	}
}
