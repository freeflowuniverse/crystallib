module doctree

import freeflowuniverse.crystallib.data.markdownparser.elements { Doc, Link }
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console

pub fn (mut page Page) doc() !&Doc {
	mut mydoc := page.doc_ or {
		mut mydoc2 := markdownparser.new(path: page.path.path, collection_name: page.collection_name)!
		&mydoc2
	}

	page.doc_ = mydoc
	return mydoc
}

@[params]
struct DocArgs {
mut:
	// heal_source bool
	dest string   @[required] // if we want to relocate images or files or pages for links, is the directory of the collection at destination !!!
	done []string
}

fn (mut page Page) doc_process_link(args_ DocArgs) !&Doc {
	mut args := args_
	mut mydoc := page.doc()!

	mut collection := page.collection()!
	args.done << page.name
	console.print_debug(' ++++ doc: ${collection.name}:${page.name} -> ${args.dest} ')

	// find the links, and for each link check if collection is same, is not need to copy
	for mut element in mydoc.children_recursive() {
		if mut element is Link {
			// console.print_debug(element)
			mut name := texttools.name_fix_keepext(element.filename)
			mut site := texttools.name_fix(element.site)
			if site == '' {
				site = collection.name
			}
			pointername := '${site}:${name}'
			if element.cat == .image {
				console.print_debug('POINTER IMAGE: ' + pointername)
				if page.tree.image_exists(pointername) {
					mut linkimage := page.tree.image_get(pointername)!
					// console.print_debug(" ------- image exists: ${pointername}")
					if args.dest.len > 0 {
						mut dest_image_copy := '${args.dest}/img/${linkimage.file_name()}'
						linkimage.copy(dest_image_copy)!
					}
					mut out := ''
					if element.extra.trim_space() == '' {
						out = '![${element.description}](img/${linkimage.file_name()})'
					} else {
						out = '![${element.description}](img/${linkimage.file_name()} ${element.extra})'
					}

					mydoc.content_set(element.id, out)
					element.processed = false
					element.process()!
				} else {
					collection.error(
						path: page.path
						msg: 'image not found: ${pointername}'
						cat: .image_not_found
					)
				}
				element.state = .linkprocessed
			} else if element.cat == .page {
				console.print_debug('POINTER PAGE: ' + pointername)
				if page.tree.page_exists(pointername) {
					mut linkpage := page.tree.page_get(pointername)!
					// this is to remember the pages which are linked
					if pointername !in mydoc.linked_pages {
						mydoc.linked_pages << pointername
					}
					console.print_debug(' ------- page exists: ${pointername}')
					mut collection_linkpage := linkpage.collection()!
					console.print_debug('${collection_linkpage.name}   ----   ${collection.name}  ')
					if args.dest.len > 0 {
						if linkpage.name !in args.done {
							mut dest_page_copy := '${args.dest}/${linkpage.name}.md'
							console.print_debug(' ------- COPY TO: ${dest_page_copy}')
							mut p_linked := pathlib.get_file(path: dest_page_copy, create: true)!
							linkdoc := linkpage.doc_process_link(args)!
							p_linked.write(linkdoc.markdown()!)!
						}
						args.done << linkpage.name
					}
					mut out := '[${element.description}](${linkpage.name}.md)'
					console.print_debug(' ------- LINKPAGE SET: ${out}')
					mydoc.content_set(element.id, out)
					element.state = .linkprocessed
				} else {
					collection.error(
						path: page.path
						msg: 'page not found: ${pointername}'
						cat: .page_not_found
					)
				}
			}
		}
	}
	return mydoc
}
