module knowledgetree

import freeflowuniverse.crystallib.pathlib { Path }

pub enum CollectionErrorCat {
	unknown
	image_double
	file_double
	file_not_found
	image_not_found
	page_double
	page_not_found
	sidebar
}

pub struct CollectionErrorArgs {
pub:
	path Path
	msg  string
	cat  CollectionErrorCat
}

pub struct CollectionError {
pub mut:
	path Path
	msg  string
	cat  CollectionErrorCat
}

pub fn (mut collection Collection) error(args CollectionErrorArgs) {
	collection.errors << CollectionError{
		path: args.path
		msg: args.msg
		cat: args.cat
	}
}
