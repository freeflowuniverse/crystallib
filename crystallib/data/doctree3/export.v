module doctree3

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools.regext
import freeflowuniverse.crystallib.data.doctree3.collection.data
import freeflowuniverse.crystallib.data.doctree3.collection
import freeflowuniverse.crystallib.core.texttools

@[params]
pub struct TreeExportArgs {
pub mut:
	dest           string @[required]
	reset          bool = true
	keep_structure bool // wether the structure of the src collection will be preserved or not
	exclude_errors bool // wether error reporting should be exported as well
	production     bool = true
	toreplace      string
}

// export all collections to chosen directory .
// all names will be in name_fixed mode .
// all images in img/
pub fn (mut tree Tree) export(args_ TreeExportArgs) ! {
	console.print_header('export tree: name:${tree.name} to ${args_.dest}')
	mut args := args_

	if args.toreplace.len > 0 {
		mut ri := regext.regex_instructions_new()
		ri.add_from_text(args.toreplace)!
		tree.replacer = ri
	}

	tree.process_includes()! // process definitions (will also do defs
	tree.process_macros()!

	mut path_src := pathlib.get_dir(path: '${args.dest}/src', create: true)!
	mut path_edit := pathlib.get_dir(path: '${args.dest}/.edit', create: true)!
	if !args.production {
		if args.reset {
			path_edit.empty()!
		}
	}

	if args.reset {
		path_src.empty()!
	}

	tree.process_pages_links()!

	for _, mut collection in tree.collections {
		collection.export(
			path_src: path_src
			path_edit: path_edit
			reset: args.reset
			keep_structure: args.keep_structure
			exclude_errors: args.exclude_errors
			production: args.production
			replacer: tree.replacer
		)!
	}
}

fn (mut t Tree) process_pages_links() ! {
	for _, mut c in t.collections {
		for _, mut p in c.pages {
			// ask page to modify doc
			t.process_page_links(mut p, mut c)!
		}
	}
}

fn (mut t Tree) process_page_links(mut page data.Page, mut c collection.Collection) ! {
	// find the links, and for each link check if collection is same, is not need to copy
	for link in page.get_doc_links()! {
		mut name := texttools.name_fix_keepext(link.filename)
		mut site := texttools.name_fix(link.site)
		if site == '' {
			site = page.collection_name
		}

		pointername := '${site}:${name}'

		mut collection_path := '.'
		if link.cat == .image {
			// console.print_debug('POINTER IMAGE: ' + pointername)
			mut linkimage := t.image_get(pointername) or {
				c.error(
					path: page.path
					msg: 'linked image not found: ${pointername}'
					cat: .image_not_found
				)

				continue
			}

			if linkimage.collection_name != page.collection_name {
				collection_path = '../${linkimage.collection_name}'
			}

			mut out := ''
			if link.extra.trim_space() == '' {
				out = '![${link.description}](${collection_path}/img/${linkimage.file_name()})'
			} else {
				out = '![${link.description}](${collection_path}/img/${linkimage.file_name()} ${link.extra})'
			}

			page.set_element_content_no_reparse(link.id, out)!
			page.reprocess_element(link.id)!
		}

		if link.cat == .page {
			mut linkpage := t.page_get(pointername) or {
				c.error(
					path: page.path
					msg: 'page not found: ${pointername}'
					cat: .page_not_found
				)

				continue
			}

			if linkpage.collection_name != page.collection_name {
				collection_path = '../${linkpage.collection_name}'
			}

			// this is to remember the pages which are linked
			if pointername !in page.get_linked_pages()! {
				page.add_linked_page(pointername)
			}

			mut out := '[${link.description}](${collection_path}/${linkpage.name}.md)'
			page.set_element_content_no_reparse(link.id, out)!
			page.reprocess_element(link.id)!
		}
	}
}
