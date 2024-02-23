module doctree

import freeflowuniverse.crystallib.data.markdownparser.elements { Doc, Link }
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import os

@[params]
pub struct DocArgs {
pub mut:
	heal_export bool = true
	// heal_source bool
	dest string // if we want to relocate images or files or pages for links, is the directory of the collection at destination !!!
	done []string
}

pub fn (page Page) doc(mut args DocArgs) !Doc {
	mut mydoc := markdownparser.new(path: page.path.path)!
	mut collection := page.collection()!
	args.done << page.name
	// println(" ++++ doc: ${collection.name}:${page.name} -> ${args.dest}  (heal:${args.heal_export})")

	if args.heal_export {
		// find the links, and for each link check if collection is same, is not need to copy
		for mut element in mydoc.children_recursive() {
			if mut element is Link {
				// println(element)
				name := texttools.name_fix(element.filename)
				mut site := texttools.name_fix(element.site)
				if site == '' {
					site = collection.name
				}
				pointername := '${site}:${name}'
				// println("POINTER "+pointername)
				if element.cat == .image {
					if page.tree.image_exists(pointername) {
						mut linkimage := page.tree.image_get(pointername)!
						// println(" ------- image exists: ${pointername}")
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
					} else {
						collection.error(
							path: page.path
							msg: 'image not found: ${pointername}'
							cat: .image_not_found
						)
					}
				}

				if element.cat == .page {
					if page.tree.page_exists(pointername) {
						mut linkpage := page.tree.page_get(pointername)!
						//this is to remember the pages which are linked
						if !(pointername in mydoc.linked_pages){
							mydoc.linked_pages << pointername
						}
						// println(" ------- page exists: ${pointername}")
						mut collection_linkpage := linkpage.collection()!
						// println("${collection_linkpage.name}   ----   ${collection.name}  ")
						// if collection_linkpage.name != collection.name {
						if args.dest.len > 0 {
							// linkpage.export(dest: dest_page_copy)!  //is always the full path
							if linkpage.name !in args.done {
								mut dest_page_copy := '${args.dest}/${linkpage.name}.md'
								mut p_linked := pathlib.get_file(path: dest_page_copy, create: true)!
								linkdoc := linkpage.doc(mut args)!
								p_linked.write(linkdoc.markdown())!
							}
							args.done << linkpage.name
						}
						// println(dest_page_copy)
						// }
						mut out := '[${element.description}](${linkpage.name}.md)'
						mydoc.content_set(element.id, out)
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
	}

	return mydoc
}
