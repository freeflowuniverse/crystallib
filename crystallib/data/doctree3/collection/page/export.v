module page

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools.regext
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.data.markdownparser.elements { Link }
import freeflowuniverse.crystallib.data.doctree3.collection
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.markdownparser.elements

@[params]
pub struct PageExportArgs {
pub mut:
	dest     string                      @[required]
	replacer ?regext.ReplaceInstructions
}

// save the page on the requested dest
// make sure the macro's are being executed
fn (mut page Page) export_page(args_ PageExportArgs) ! {
	mut args := args_

	// TODO: should not be necessary
	page.reparse_doc()!

	page.process_macros()!

	mut p := pathlib.get_file(path: args.dest, create: true)!
	dirpath := p.parent()!

	page.process_page_links(dest: dirpath.path)!
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

fn (mut page Page) process_page_links(args_ DocArgs) ! {
	mut errs := PageMultiError{}
	mut args := args_
	mut mydoc := page.doc()!

	args.done << page.name
	// console.print_debug('++++ process links doc: ${collection.name}:${page.name} -> ${args.dest} ')

	// find the links, and for each link check if collection is same, is not need to copy
	for mut element in mydoc.children_recursive() {
		if mut element is Link {
			// console.print_debug(element)
			mut name := texttools.name_fix_keepext(element.filename)
			mut site := texttools.name_fix(element.site)
			if site == '' {
				site = page.collection_name
			}
			pointername := '${site}:${name}'

			mut collection_path := '.'
			if element.cat == .image {
				// console.print_debug('POINTER IMAGE: ' + pointername)
				mut linkimage := t.image_get(pointername) or {
					errs.errs << PageError{
						path: page.path
						msg: 'image not found: ${pointername}'
						cat: .image_not_found
					}

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
					errs.errs << PageError(
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

	if errs.errs.len > 0 {
		return errs
	}
}
