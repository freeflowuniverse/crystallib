module doctree

// import os
import freeflowuniverse.crystallib.tools.imagemagick
import freeflowuniverse.crystallib.core.pathlib { Path }
import freeflowuniverse.crystallib.data.markdownparser

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
	pages  map[string]&Page // markdown pages in playbook
	files  map[string]&File
	images map[string]&File
	path   Path
	errors []CollectionError
	state  CollectionState
	tree   &Tree             @[str: skip]
	heal   bool
}

// format of name is $playbookname:$pagename or $pagename
// look if we can find page in the local playbook is playbook name not specified
// if playbookname specified will look for page in that specific playbook
pub fn (playbook Collection) page_get(name_ string) !&Page {
	_, name := name_parse(name_)!
	return playbook.pages[name] or { return ObjNotFound{
		playbook: playbook.name
		name: name
	} }
}

pub fn (playbook Collection) image_get(name_ string) !&File {
	_, name := name_parse(name_)!
	return playbook.images[name] or {
		return ObjNotFound{
			playbook: playbook.name
			name: name
		}
	}
}

pub fn (playbook Collection) file_get(name_ string) !&File {
	_, name := name_parse(name_)!
	return playbook.files[name] or { return ObjNotFound{
		playbook: playbook.name
		name: name
	} }
}

pub fn (playbook Collection) page_exists(name string) bool {
	_ := playbook.page_get(name) or {
		if err is ObjNotFound {
			return false
		} else {
			panic(err) // catch unforseen errors
		}
	}
	return true
}

pub fn (playbook Collection) image_exists(name string) bool {
	_ := playbook.image_get(name) or {
		if err is ObjNotFound {
			return false
		} else {
			panic(err)
		}
	}
	return true
}

pub fn (playbook Collection) file_exists(name string) bool {
	_ := playbook.file_get(name) or {
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
fn (mut playbook Collection) file_image_remember(mut p Path) ! {
	$if debug {
		println('file or image remember: ${p.path}')
	}
	mut ptr := pointerpath_new(path: p.path, path_normalize: playbook.heal, needs_to_exist: true)!
	p = ptr.path
	if ptr.is_image() {
		if playbook.heal && imagemagick.installed() {
			mut image := imagemagick.image_new(mut p) or {
				panic('Cannot get new image:\n${p}\n${err}')
			}
			$if debug {
				println('downsizing image ${p.path}')
			}
			imagemagick.downsize(path: p.path)!
			// after downsize it could be the path has been changed, need to set it on the file
			if p.path != image.path.path {
				p.path = image.path.path
				p.check()
			}
		}
		if playbook.image_exists(ptr.pointer.name) {
			mut filedouble := playbook.image_get(ptr.pointer.name) or {
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
			if playbook.heal {
				p.delete()!
			}
			return
		} else {
			// means the its a new one, lets add it, first see if it needs to be downsized
			playbook.image_new(mut p)!
		}
	} else if ptr.is_file_video_html() {
		// now we are working on non image
		// if playbook.file_exists(ptr.pointer.name) {
		// 	mut filedouble := playbook.file_get(ptr.pointer.name)!
		// 	mut pathdouble := filedouble.path
		// 	playbook.error(path: pathdouble, msg: 'duplicate file', cat: .image_double)
		// } else {
		// }

		// file existence is checked in file_new
		playbook.file_new(mut ptr.path)!
	} else {
		panic('unknown obj type, bug')
	}
}

// add a page to the playbook, specify existing path
// the page will be parsed as markdown
pub fn (mut playbook Collection) page_new(mut p Path) ! {
	$if debug {
		println('playbook: ${playbook.name} page new: ${p.path}')
	}
	mut ptr := pointerpath_new(path: p.path, path_normalize: playbook.heal, needs_to_exist: false)!
	// in case heal is true pointerpath_new can normalize the path
	p = ptr.path
	if playbook.page_exists(ptr.pointer.name) {
		playbook.error(
			path: p
			msg: 'Can\'t add ${p.path}: a page named ${ptr.pointer.name} already exists in the playbook'
			cat: .page_double
		)
		return
	}
	mut doc := markdownparser.new(path: p.path)!
	mut page := &Page{
		doc: doc
		pathrel: p.path_relative(playbook.path.path)!.trim('/')
		name: ptr.pointer.name
		path: p
		readonly: false
		pages_linked: []&Page{}
		tree: playbook.tree
		playbook_name: playbook.name
	}
	playbook.pages[ptr.pointer.name] = page
}

// add a file to the playbook, specify existing path
pub fn (mut playbook Collection) file_new(mut p Path) ! {
	$if debug {
		println('playbook: ${playbook.name} file new: ${p.path}')
	}
	mut ptr := pointerpath_new(path: p.path, path_normalize: playbook.heal, needs_to_exist: true)!
	// in case heal is true pointerpath_new can normalize the path
	p = ptr.path
	if playbook.file_exists(ptr.pointer.name) {
		playbook.error(
			path: p
			msg: 'Can\'t add ${p.path}: a file named ${ptr.pointer.name} already exists in the playbook'
			cat: .file_double
		)
		return
	}

	mut ff := &File{
		path: p
		playbook: &playbook
	}
	ff.init()
	playbook.files[ptr.pointer.name] = ff
}

// add a image to the playbook, specify existing path
pub fn (mut playbook Collection) image_new(mut p Path) ! {
	$if debug {
		println('playbook: ${playbook.name} image new: ${p.path}')
	}
	mut ptr := pointerpath_new(path: p.path, path_normalize: playbook.heal, needs_to_exist: true)!
	if ptr.pointer.name.starts_with('.') {
		panic('should not start with . \n${p}')
	}
	// in case heal is true pointerpath_new can normalize the path
	p = ptr.path
	if playbook.image_exists(ptr.pointer.name) {
		// remove this one
		mut file_double := playbook.image_get(p.name())!
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
		playbook: &playbook
	}
	ff.init()
	playbook.images[ptr.pointer.name] = ff
}

// go over all pages, fix the links, check the images are there
pub fn (mut playbook Collection) fix() ! {
	$if debug {
		println('playbook fix: ${playbook.name}')
	}
	for _, mut page in playbook.pages {
		page.fix()!
	}
	playbook.errors_report('${playbook.path.path}/errors.md')!
}

// return all pagenames for a playbook
pub fn (playbook Collection) pagenames() []string {
	mut res := []string{}
	for key, _ in playbook.pages {
		res << key
	}
	res.sort()
	return res
}

// write errors.md in the playbook, this allows us to see what the errors are
fn (playbook Collection) errors_report(where string) ! {
	mut p := pathlib.get('${where}')
	if playbook.errors.len == 0 {
		p.delete()!
		return
	}
	c := $tmpl('template/errors.md')
	p.write(c)!
}
