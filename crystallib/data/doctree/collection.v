module doctree

// import os
import freeflowuniverse.crystallib.tools.imagemagick
import freeflowuniverse.crystallib.core.pathlib { Path }
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.ui.console

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
	pages  map[string]&Page // markdown pages in collection
	files  map[string]&File
	images map[string]&File
	path   Path
	errors []CollectionError
	state  CollectionState
	tree   &Tree             @[str: skip]
	heal   bool = true
}

// format of name is $collectionname:$pagename or $pagename
// look if we can find page in the local collection is collection name not specified
// if collectionname specified will look for page in that specific collection
pub fn (collection Collection) page_get(name_ string) !&Page {
	_, name := name_parse(name_)!
	return collection.pages[name] or {
		return ObjNotFound{
			collection: collection.name
			name: name
		}
	}
}

pub fn (collection Collection) image_get(name_ string) !&File {
	_, name := name_parse(name_)!
	return collection.images[name] or {
		return ObjNotFound{
			collection: collection.name
			name: name
		}
	}
}

pub fn (collection Collection) file_get(name_ string) !&File {
	_, name := name_parse(name_)!
	return collection.files[name] or {
		return ObjNotFound{
			collection: collection.name
			name: name
		}
	}
}

pub fn (collection Collection) page_exists(name string) bool {
	_ := collection.page_get(name) or {
		if err is ObjNotFound {
			return false
		} else {
			panic(err) // catch unforseen errors
		}
	}
	return true
}

pub fn (collection Collection) image_exists(name string) bool {
	_ := collection.image_get(name) or {
		if err is ObjNotFound {
			return false
		} else {
			panic(err)
		}
	}
	return true
}

pub fn (collection Collection) file_exists(name string) bool {
	_ := collection.file_get(name) or {
		if err is ObjNotFound {
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
fn (mut collection Collection) file_image_remember(mut p Path) ! {
	$if debug {
		console.print_debug('file or image remember: ${p.path}')
	}
	mut ptr := pointerpath_new(path: p.path, path_normalize: collection.heal, needs_to_exist: true)!
	p = ptr.path
	if ptr.is_image() {
		if collection.heal && imagemagick.installed() {
			mut image := imagemagick.image_new(mut p) or {
				panic('Cannot get new image:\n${p}\n${err}')
			}
			$if debug {
				console.print_debug('downsizing image ${p.path}')
			}
			imagemagick.downsize(path: p.path)!
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
				p.delete()!
			}
			return
		} else {
			// means the its a new one, lets add it, first see if it needs to be downsized
			collection.image_new(mut p)!
		}
	} else if ptr.is_file_video_html() {
		// now we are working on non image
		// if collection.file_exists(ptr.pointer.name) {
		// 	mut filedouble := collection.file_get(ptr.pointer.name)!
		// 	mut pathdouble := filedouble.path
		// 	collection.error(path: pathdouble, msg: 'duplicate file', cat: .image_double)
		// } else {
		// }

		// file existence is checked in file_new
		collection.file_new(mut ptr.path)!
	} else {
		panic('unknown obj type, bug')
	}
}

// add a page to the collection, specify existing path
// the page will be parsed as markdown
pub fn (mut collection Collection) page_new(mut p Path) ! {
	$if debug {
		console.print_debug('collection: ${collection.name} page new: ${p.path}')
	}
	mut ptr := pointerpath_new(path: p.path, path_normalize: collection.heal, needs_to_exist: false)!
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
	mut page := &Page{
		pathrel: p.path_relative(collection.path.path)!.trim('/')
		name: ptr.pointer.name
		path: p
		readonly: false
		// pages_linked: []&Page{}
		tree: collection.tree
		collection_name: collection.name
	}
	collection.pages[ptr.pointer.name] = page
}

// add a file to the collection, specify existing path
pub fn (mut collection Collection) file_new(mut p Path) ! {
	$if debug {
		console.print_debug('collection: ${collection.name} file new: ${p.path}')
	}
	mut ptr := pointerpath_new(path: p.path, path_normalize: collection.heal, needs_to_exist: true)!
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

	mut ff := &File{
		path: p
		collection: &collection
	}
	ff.init()
	collection.files[ptr.pointer.name] = ff
}

// add a image to the collection, specify existing path
pub fn (mut collection Collection) image_new(mut p Path) ! {
	$if debug {
		console.print_debug('collection: ${collection.name} image new: ${p.path}')
	}
	mut ptr := pointerpath_new(path: p.path, path_normalize: collection.heal, needs_to_exist: true)!
	if ptr.pointer.name.starts_with('.') {
		panic('should not start with . \n${p}')
	}
	// in case heal is true pointerpath_new can normalize the path
	p = ptr.path
	if collection.image_exists(ptr.pointer.name) {
		// remove this one
		mut file_double := collection.image_get(p.name())!
		mut path_double := file_double.path
		if p.path.len > path_double.path.len {
			p.delete()!
		} else {
			path_double.delete()!
			file_double.path = p // reset the path so the shortest one remains
		}
		return
	}
	mut ff := &File{
		path: p
		collection: &collection
	}
	ff.init()
	collection.images[ptr.pointer.name] = ff
}

// go over all pages, fix the links, check the images are there
pub fn (mut collection Collection) fix() ! {
	$if debug {
		console.print_debug('collection fix: ${collection.name}')
	}
	for _, mut page in collection.pages {
		page.fix()!
	}
	collection.errors_report('${collection.path.path}/errors.md')!
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
fn (collection Collection) errors_report(dest_ string) ! {	
	mut dest:=pathlib.get_file(path:dest_,create:true)!
	if collection.errors.len == 0 {
		dest.delete()!
		return
	}
	c := $tmpl('template/errors.md')
	dest.write(c)!
}
