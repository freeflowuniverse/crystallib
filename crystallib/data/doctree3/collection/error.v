module collection

import freeflowuniverse.crystallib.core.pathlib { Path }
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.data.doctree3.collection.data

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
	def
	summary
	include
}

pub struct CollectionError {
	Error
pub mut:
	path Path
	msg  string
	cat  CollectionErrorCat
}

pub fn (mut collection Collection) error(args CollectionError) {
	ce := CollectionError{
		path: args.path
		msg: args.msg
		cat: args.cat
	}

	if ce !in collection.errors {
		collection.errors << ce
	}

	console.print_stderr(args.msg)
}

pub fn (mut c Collection) add_page_multi_error(multierr data.PageMultiError) {
	for err in multierr.errs {
		c.add_page_error(err)
	}
}

pub fn (mut c Collection) add_page_error(err data.PageError) {
	cat := match err.cat {
		.file_not_found { CollectionErrorCat.file_not_found }
		.image_not_found { CollectionErrorCat.page_not_found }
		.page_not_found { CollectionErrorCat.page_not_found }
		.def { CollectionErrorCat.def }
		else { CollectionErrorCat.unknown }
	}

	c.error(
		path: err.path
		msg: err.msg
		cat: cat
	)
}

pub struct ObjNotFound {
	Error
pub:
	name       string
	collection string
	info       string
}

pub fn (err ObjNotFound) msg() string {
	return '"Could not find object with name ${err.name} in collection:${err.collection}.\n${err.info}'
}

// write errors.md in the collection, this allows us to see what the errors are
pub fn (collection Collection) errors_report(dest_ string) ! {
	// console.print_debug("====== errors report: ${dest_} : ${collection.errors.len}\n${collection.errors}")
	mut dest := pathlib.get_file(path: dest_, create: true)!
	if collection.errors.len == 0 {
		dest.delete()!
		return
	}
	c := $tmpl('template/errors.md')
	dest.write(c)!
}
