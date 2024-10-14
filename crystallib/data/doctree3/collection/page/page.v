module page

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.markdownparser.elements { Doc }
import freeflowuniverse.crystallib.data.markdownparser

pub enum PageStatus {
	unknown
	ok
	error
}

@[heap]
pub struct Page {
mut:
	doc &Doc @[str: skip]
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
}

@[params]
pub struct NewPageArgs {
pub:
	name            string       @[required]
	path            pathlib.Path @[required]
	pathrel         string       @[required]
	readonly        bool
	collection_name string       @[required]
}

pub fn new(args NewPageArgs) !Page {
	if args.collection_name == '' {
		return error('page collection name must not be empty')
	}

	if args.name == '' {
		return error('page name must not be empty')
	}

	mut doc := markdownparser.new(path: args.path.path, collection_name: args.collection_name)!
	mut new_page := Page{
		pathrel: args.pathrel
		name: args.name
		path: args.path
		readonly: args.readonly
		collection_name: args.collection_name
		doc: &doc
	}

	return new_page
}

// return doc, reparse if needed
pub fn (mut page Page) doc() !&Doc {
	if page.changed {
		page.reparse_doc()!
	}

	page.changed = false
	return page.doc
}

// reparse doc markdown and assign new doc to page
fn (mut page Page) reparse_doc() ! {
	doc := markdownparser.new(path: page.doc.markdown()!, collection_name: page.collection_name)!
	page.doc = &doc
}

pub fn (page Page) key() string {
	return '${page.collection_name}:${page.name}'
}
