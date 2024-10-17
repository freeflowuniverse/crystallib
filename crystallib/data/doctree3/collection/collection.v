module collection

import freeflowuniverse.crystallib.conversiontools.imagemagick
import freeflowuniverse.crystallib.core.pathlib { Path }
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.data.doctree3.pointer
import freeflowuniverse.crystallib.data.doctree3.collection.data
import freeflowuniverse.crystallib.core.texttools

pub enum CollectionState {
	init
	initdone
	scanned
	fixed
	ok
}

@[heap]
pub struct Collection {
pub:
	name string
pub mut:
	title  string
	pages  map[string]&data.Page // markdown pages in collection
	files  map[string]&data.File
	images map[string]&data.File
	path   Path
	errors []CollectionError
	state  CollectionState
	heal   bool = true
}

@[params]
pub struct CollectionNewArgs {
mut:
	name string @[required]
	path string @[required]
	heal bool = true // healing means we fix images, if selected will automatically load, remove stale links
	load bool = true
}

// get a new collection
pub fn new(args_ CollectionNewArgs) !Collection {
	mut args := args_
	args.name = texttools.name_fix(args.name)

	mut pp := pathlib.get_dir(path: args.path)! // will raise error if path doesn't exist
	mut collection := Collection{
		name: args.name
		path: pp
		heal: args.heal
	}

	if args.load {
		collection.scan()!
	}

	return collection
}

// remember the file, so we know if we have duplicates
// also fixes the name
fn (mut collection Collection) file_image_remember(mut p Path) ! {
	$if debug {
		console.print_debug('file or image remember: ${p.path}')
	}
	mut ptr := pointer.pointerpath_new(
		path: p.path
		path_normalize: collection.heal
		needs_to_exist: true
	)!

	p = ptr.path
	if ptr.is_file_video_html() {
		collection.file_new(mut p)!
		return
	}

	if ptr.is_image() {
		if collection.heal && imagemagick.installed() {
			mut image := imagemagick.image_new(mut p)

			imagemagick.downsize(path: p.path)!
			// after downsize it could be the path has been changed, need to set it on the file
			if p.path != image.path.path {
				p.path = image.path.path
				p.check()
			}
		}

		// TODO: what are we trying to do?
		if !collection.image_exists(ptr.pointer.name) {
			collection.image_new(mut p)!
		}

		mut image_file := collection.get_image(ptr.pointer.name)!
		mut image_file_path := image_file.path.path
		if p.path.len <= image_file_path.len {
			// nothing to be done, because the already existing file is shortest or equal
			return
		}
		// file double is the one who already existed, need to change the path and can delete original
		// TODO: this is clearly a bug
		image_file.path = image_file.path
		image_file.init()!
		if collection.heal {
			p.delete()!
		}

		return
	}

	return error('unsupported file type: ${ptr.pointer.extension}')
}

// add a page to the collection, specify existing path
// the page will be parsed as markdown
pub fn (mut collection Collection) page_new(mut p Path) ! {
	mut ptr := pointer.pointerpath_new(
		path: p.path
		path_normalize: collection.heal
		needs_to_exist: true
	)!

	// in case heal is true pointerpath_new can normalize the path
	p = ptr.path
	if collection.page_exists(ptr.pointer.name) {
		collection.error(
			path: p
			msg: 'Can\'t add ${p.path}: a page named ${ptr.pointer.name} already exists in the collection'
			cat: .page_double
		)
		return
	}

	new_page := data.new_page(
		name: ptr.pointer.name
		path: p
		collection_name: collection.name
	)!

	collection.pages[ptr.pointer.name] = &new_page
}

// add a file to the collection, specify existing path
pub fn (mut collection Collection) file_new(mut p Path) ! {
	mut ptr := pointer.pointerpath_new(
		path: p.path
		path_normalize: collection.heal
		needs_to_exist: true
	)!

	// in case heal is true pointerpath_new can normalize the path
	p = ptr.path
	if collection.file_exists(ptr.pointer.name) {
		collection.error(
			path: p
			msg: 'Can\'t add ${p.path}: a file named ${ptr.pointer.name} already exists in the collection'
			cat: .file_double
		)
		return
	}

	mut new_file := data.new_file(
		path: p
		collection_path: collection.path
		collection_name: collection.name
	)!
	collection.files[ptr.pointer.name] = &new_file
}

// add a image to the collection, specify existing path
pub fn (mut collection Collection) image_new(mut p Path) ! {
	mut ptr := pointer.pointerpath_new(
		path: p.path
		path_normalize: collection.heal
		needs_to_exist: true
	)!

	// in case heal is true pointerpath_new can normalize the path
	if collection.image_exists(ptr.pointer.name) {
		// remove this one
		// TODO: why remove, what if this is a whole other image, but has the same name???
		mut file_double := collection.get_image(ptr.path.name())!
		mut path_double := file_double.path
		if ptr.path.path.len > path_double.path.len {
			ptr.path.delete()!
		} else {
			path_double.delete()!
			file_double.path = ptr.path // reset the path so the shortest one remains
		}
		return
	}

	mut image_file := &data.File{
		path: ptr.path
		collection_path: collection.path
	}
	image_file.init()!
	collection.images[ptr.pointer.name] = image_file
}

// return all pagenames for a collection
pub fn (collection Collection) pagenames() []string {
	mut res := []string{}
	for key, _ in collection.pages {
		res << key
	}
	res.sort()
	return res
}
