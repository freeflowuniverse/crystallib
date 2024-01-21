module doctree

import freeflowuniverse.crystallib.core.pathlib { Path }

pub enum CollectionErrorCat {
	unknown
	image_double
	file_double
	file_not_found
	image_not_found
	page_double
	page_not_found
	sidebar
	circular_import
}

pub struct CollectionError {
	Error
pub mut:
	path Path
	msg  string
	cat  CollectionErrorCat
}

pub fn (mut collection Collection) error(args CollectionError) {
	collection.errors << CollectionError{
		path: args.path
		msg: args.msg
		cat: args.cat
	}
}

pub struct ObjNotFound {
	Error
pub:
	name     string
	collection string
}

pub fn (err ObjNotFound) msg() string {
	return '"Could not find object with name ${err.name} in collection:${err.collection}'
}
