module knowledgetree

// import os
import freeflowuniverse.crystallib.imagemagick
import freeflowuniverse.crystallib.pathlib { Path }
import freeflowuniverse.crystallib.markdowndocs

pub enum CollectionState {
	init
	initdone
	scanned
	fixed
	ok
}

[heap]
pub struct Collection {
pub:
	name string
pub mut:
	title string
	// collections  &Collections           [str: skip] // pointer to collections
	pages  map[string]&Page
	files  map[string]&File
	images map[string]&File
	path   Path
	errors []CollectionError
	state  CollectionState
	heal   bool
	tree   &Tree
}

// walk over one specific collection, find all files and pages
pub fn (mut collection Collection) scan() ! {
	$if debug {
		println(' - load collection: ${collection.name} - ${collection.path.path}')
	}
	collection.scan_internal(mut collection.path)!
	$if debug {
		println('scan done')
	}
}

///////////// PAGE/IMAGE/FILE GET

pub struct CollectionObjNotFound {
	Error
pub:
	name    string
	cat     string
	collection string
}

pub fn (err CollectionObjNotFound) msg() string {
	return '"Could not find object of type ${err.cat} with name ${err.name} in collection:${err.collection}'
}

// format of name is $collectionname:$pagename or $pagename
// look if we can find page in the local collection is collection name not specified
// if collectionname specified will look for page in that specific collection
pub fn (collection Collection) page_get(name string) !&Page {
	cat := 'page'
	ptr := pointer_new(name)!
	if ptr.collection != '' && ptr.collection != collection.name {
		return error("Can't get in collection, collection name asked for is ${ptr.collection} while we are in chaptner ${collection.name}")
	}
	if ptr.name in collection.pages {
		return collection.pages[ptr.name] or {
			return CollectionObjNotFound{
				cat: cat
				collection: collection.name
				name: ptr.name
			}
		}
	}
	return CollectionObjNotFound{
		cat: cat
		collection: collection.name
		name: ptr.name
	}
}

pub fn (collection Collection) file_get(name string) !&File {
	cat := 'file'
	ptr := pointer_new(name)!
	if ptr.collection != '' && ptr.collection != collection.name {
		return error("Can't get in collection, collection name asked for is ${ptr.collection} while we are in chaptner ${collection.name}")
	}
	if ptr.name in collection.files {
		return collection.files[ptr.name] or {
			return CollectionObjNotFound{
				cat: cat
				collection: collection.name
				name: ptr.name
			}
		}
	}
	return CollectionObjNotFound{
		cat: cat
		collection: collection.name
		name: ptr.name
	}
}

pub fn (collection Collection) image_get(name string) !&File {
	cat := 'image'
	ptr := pointer_new(name)!
	if ptr.collection != '' && ptr.collection != collection.name {
		return error("Can't get in collection, collection name asked for is ${ptr.collection} while we are in chaptner ${collection.name}")
	}
	if ptr.name in collection.images {
		return collection.images[ptr.name] or {
			return CollectionObjNotFound{
				cat: cat
				collection: collection.name
				name: ptr.name
			}
		}
	}
	return CollectionObjNotFound{
		cat: cat
		collection: collection.name
		name: ptr.name
	}
}

pub fn (collection Collection) page_exists(name string) bool {
	_ := collection.page_get(name) or {
		if err is CollectionObjNotFound {
			return false
		} else {
			panic(err) // catch unforseen errors
		}
	}
	return true
}

pub fn (collection Collection) image_exists(name string) bool {
	_ := collection.image_get(name) or {
		if err is CollectionObjNotFound {
			return false
		} else {
			panic(err)
		}
	}
	return true
}

pub fn (collection Collection) file_exists(name string) bool {
	_ := collection.file_get(name) or {
		if err is CollectionObjNotFound {
			return false
		} else {
			panic(err)
		}
	}
	return true
}

///////////////////////////////////////////////////////////


// remember the file, so we know if we have duplicates
// also fixes the name
fn (mut collection Collection) file_image_remember(mut p pathlib.Path) ! {
	$if debug {
		eprintln(' - file or image remember : ${p.path}')
	}
	mut ptr := pointerpath_new(path: p.path, path_normalize: true, needs_to_exist: true)! //TODO: seems like some overkill
	p = ptr.path
	if ptr.is_image() {
		if collection.heal && imagemagick.installed() {
			mut image := imagemagick.image_new(mut p) or {
				panic('Cannot get new image:\n${p}\n${err}')
			}
			image.downsize(backup: false)!
			// after downsize it could be the path has been changed, need to set it on the file
			if p.path != image.path.path {
				p.path = image.path.path
				p.check()
			}
		}
		if collection.image_exists(ptr.pointer.name) {
			mut filedouble := collection.image_get(ptr.pointer.name) or {
				panic('if image exists, I should be able to get it. \n${err}')
			}
			mut pathdouble := filedouble.path.path
			mut pathsource := p.path
			if pathsource.len < pathdouble.len + 1 {
				// nothing to be done, because the already existing file is shortest or equal
				return
			}
			// file double is the one who already existed, need to change the path and can delete original
			filedouble.path = filedouble.path
			filedouble.init()
			if collection.heal {
				println(' - delete double image: ${p.path}')
				p.delete()!
			}
			return
		} else {
			// means the its a new one, lets add it, first see if it needs to be downsized
			collection.image_new(mut p)!
		}
	} else if ptr.is_file_video_html() {
		// now we are working on non image
		if collection.file_exists(ptr.pointer.name) {
			mut filedouble := collection.file_get(ptr.pointer.name)!
			mut pathdouble := filedouble.path
			collection.error(path: pathdouble, msg: 'duplicate file', cat: .image_double)
		} else {
			collection.file_new(mut ptr.path)!
		}
	} else {
		panic('unknown obj type, bug')
	}
}


// add a page to the collection, specify existing path
// the page will be parsed as markdown
pub fn (mut collection Collection) page_new(mut p Path) !&Page {
	$if debug {
		println(" - collection:'${collection.name}' page new: ${p.path}")
	}
	mut ptr := pointerpath_new(path: p.path, path_normalize: true, needs_to_exist: true)!
	mut doc := markdowndocs.new(path: p.path) or { panic('cannot parse,${err}') }
	mut page := Page{
		doc: &doc
		pathrel: p.path_relative(collection.path.path)!.trim('/')
		name: ptr.pointer.name
		path: p
		collection: &collection
		readonly: false
	}
	collection.pages[ptr.pointer.name] = &page
	return collection.pages[ptr.pointer.name] or {
		return error('Cannot find page ${ptr.pointer.name} in collection: ${collection.name}')
	}
}

// add a file to the collection, specify existing path
pub fn (mut collection Collection) file_new(mut p Path) ! {
	$if debug {
		println(" - collection:'${collection.name}' file new: ${p.path}")
	}
	mut ptr := pointerpath_new(path: p.path, path_normalize: true, needs_to_exist: true)!
	mut ff := File{
		path: p
		collection: &collection
	}
	ff.init()
	collection.files[ptr.pointer.name] = &ff
}

// add a image to the collection, specify existing path
pub fn (mut collection Collection) image_new(mut p Path) ! {
	$if debug {
		println(" - collection:'${collection.name}' image new: ${p.path}")
	}

	mut ptr := pointerpath_new(path: p.path, path_normalize: true, needs_to_exist: true)!
	if ptr.pointer.name.starts_with('.') {
		panic('should not start with . \n${p}')
	}
	if collection.image_exists(ptr.pointer.name) {
		// TODO: fix doubles

		// remove this one
		// mut file_double := collection.image_get(p.name())!
		// mut path_double := file_double.path
		// if p.path.len > path_double.path.len {
		// 	p.delete()!
		// } else {
		// 	path_double.delete()!
		// 	file_double.path = p // reset the path so the shortest one remains
		// }
		return
	}
	mut ff := File{
		path: p
		collection: &collection
	}
	ff.init()
	collection.images[ptr.pointer.name] = &ff
}

// go over all pages, fix the links, check the images are there
pub fn (mut collection Collection) fix() ! {
	$if debug {
		println(' --- collection fix: ${collection.name}')
	}
	for _, mut page in collection.pages {
		page.fix()!
	}
	collection.errors_report()!
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

// write errors.md in the collection, this allows us to see what the errors are
pub fn (collection Collection) errors_report() ! {
	mut p := pathlib.get('${collection.path.path}/errors.md')
	if collection.errors.len == 0 {
		p.delete()!
		return
	}
	c := $tmpl('template/errors_collection.md')
	p.write(c)!
}