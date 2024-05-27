module doctree

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.markdownparser.elements { Doc }
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.ui.console

pub enum PageStatus {
	unknown
	ok
	error
}

@[heap]
pub struct Page {
	tree &Tree @[str: skip]
pub mut:
	name    string // received a name fix
	alias   string // a proper name for e.g. def
	path    pathlib.Path
	pathrel string // relative path in the collection
	state   PageStatus
	// pages_included  []&Page      @[str: skip]
	// pages_linked    []&Page      @[str: skip]
	// files_linked    []&File      @[str: skip]
	categories      []string
	readonly        bool
	changed         bool
	collection_name string
	doc_            ?&Doc    @[str: skip]
}

fn (page Page) collection() !&Collection {
	collection := page.tree.collections[page.collection_name] or {
		return error("could not find collection:'${page.collection_name}' in tree: ${page.tree.name}")
	}
	return collection
}

pub fn (page Page) key() string {
	if page.collection_name.len == 0 {
		panic('name cannot be empty for page: ${page.path.path}')
	}
	if page.name.len == 0 {
		panic('name cannot be empty for page: ${page.path.path}')
	}
	return '${page.collection_name}:${page.name}'
}

// fn (mut page Page) fix() ! {
// page.fix_links()!
// // TODO: do includes
// if page.changed {
// 	$if debug {
// 		console.print_debug('CHANGED: ${page.path}')
// 	}
// 	page.save()!
// 	page.changed = false
// }
// }

@[params]
pub struct PageExportArgs {
pub mut:
	dest string @[required]
}

// save the page on the requested dest
// make sure the macro's are being executed
pub fn (mut page Page) export(args_ PageExportArgs) !&Doc {
	mut args := args_
	// if args.dest == '' {
	// 	args.dest = page.path.path
	// }
	mut doc := markdownparser.new(content: page.doc()!.markdown()!)!
	page.doc_ = &doc

	console.print_debug(' ++++ export: ${page.name} -> ${args.dest}')
	mut p := pathlib.get_file(path: args.dest, create: true)!
	dirpath := p.parent()!
	// mut mydoc := page.doc()!
	mut mydoc := page.doc_process_link(dest: dirpath.path)!
	p.write(mydoc.markdown()!)!
	return mydoc
}

// save the page on the requested dest
// make sure the macro's are being executed
// pub fn (mut page Page) save(args_ PageExportArgs) ! {
// 	mut args := args_
// 	if args.dest == '' {
// 		args.dest = page.path.path
// 	}
// 	// page.process_macros()!
// 	// page.fix_links()! // always need to make sure that the links are now clean
// 	// QUESTION: okay convention?
// 	out := page.doc or { panic('this should never happen') }.markdown()
// 	mut p := pathlib.get_file(path: args.dest, check: false)!
// 	p.write(out)!

// 	// mutate page to save updated doc
// 	updated_doc := markdownparser.new(path: p.path) or { panic('cannot parse,${err}') }
// 	page.doc = updated_doc
// }
