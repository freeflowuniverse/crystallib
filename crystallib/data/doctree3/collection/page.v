module collection

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.markdownparser.elements { Doc }
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools.regext

pub enum PageStatus {
	unknown
	ok
	error
}

@[heap]
pub struct Page {
	// tree &Tree @[str: skip]
pub mut:
	name            string // received a name fix
	alias           string // a proper name for e.g. def
	path            pathlib.Path
	pathrel         string // relative path in the collection
	state           PageStatus
	categories      []string
	readonly        bool
	changed         bool
	collection_name string
	doc_            ?&Doc        @[str: skip]
}

// fn (page Page) collection() !&Collection {
// 	collection := page.tree.collections[page.collection_name] or {
// 		return error("could not find collection:'${page.collection_name}' in tree: ${page.tree.name}")
// 	}
// 	return collection
// }

pub fn (page Page) key() string {
	if page.collection_name.len == 0 {
		panic('name cannot be empty for page: ${page.path.path}')
	}
	if page.name.len == 0 {
		panic('name cannot be empty for page: ${page.path.path}')
	}
	return '${page.collection_name}:${page.name}'
}

// @[params]
// pub struct PageExportArgs {
// pub mut:
// 	dest     string                      @[required]
// 	replacer ?regext.ReplaceInstructions
// }

// // save the page on the requested dest
// // make sure the macro's are being executed
// pub fn (mut page Page) export(args_ PageExportArgs) !&Doc {
// 	mut args := args_
// 	// if args.dest == '' {
// 	// 	args.dest = page.path.path
// 	// }

// 	mut doc := markdownparser.new(content: page.doc()!.markdown()!)!
// 	page.doc_ = &doc

// 	page.doc_process()!

// 	// console.print_debug(' ++++ export: ${page.name} -> ${args.dest}')
// 	mut p := pathlib.get_file(path: args.dest, create: true)!
// 	dirpath := p.parent()!
// 	// mut mydoc := page.doc()!
// 	mut mydoc := page.doc_process_link(dest: dirpath.path)!
// 	mut c := mydoc.markdown()!
// 	if args.replacer != none {
// 		c = args.replacer or { panic('bug') }.replace(text: c)!
// 	}
// 	p.write(c)!
// 	return mydoc
// }
