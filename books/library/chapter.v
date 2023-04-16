module library

// import os
import freeflowuniverse.crystallib.pathlib { Path }
import freeflowuniverse.crystallib.markdowndocs

pub enum ChapterState {
	init
	initdone
	scanned
	fixed
	ok
}

[heap]
pub struct Chapter {
pub:
	name string
pub mut:
	title string
	// chapters  &Chapters           [str: skip] // pointer to chapters
	pages  map[string]&Page
	files  map[string]&File
	images map[string]&File
	path   Path
	errors []ChapterError
	state  ChapterState
	heal   bool
	book   &Book
}

// walk over one specific chapter, find all files and pages
pub fn (mut chapter Chapter) scan() ! {
	$if debug {
		println(' - load chapter: ${chapter.name} - ${chapter.path.path}')
	}
	chapter.scan_internal(mut chapter.path)!
	$if debug {
		println('scan done')
	}
}

///////////// PAGE/IMAGE/FILE GET

pub struct ChapterObjNotFound {
	Error
pub:
	name    string
	cat     string
	chapter string
}

pub fn (err ChapterObjNotFound) msg() string {
	return '"Could not find object of type ${err.cat} with name ${err.name} in chapter:${err.chapter}'
}

// format of name is $chaptername:$pagename or $pagename
// look if we can find page in the local chapter is chapter name not specified
// if chaptername specified will look for page in that specific chapter
pub fn (mut chapter Chapter) page_get(name string) !&Page {
	cat := 'page'
	ptr := pointer.pointer_new(name)!
	if ptr.chapter != '' && ptr.chapter != chapter.name {
		return error("Can't get in chapter, chapter name asked for is ${ptr.chapter} while we are in chaptner ${chapter.name}")
	}
	if ptr.name in chapter.pages {
		return chapter.pages[ptr.name] or {
			return ChapterObjNotFound{
				cat: cat
				chapter: chapter.name
				name: ptr.name
			}
		}
	}
	return ChapterObjNotFound{
		cat: cat
		chapter: chapter.name
		name: ptr.name
	}
}

pub fn (mut chapter Chapter) file_get(name string) !&File {
	cat := 'file'
	ptr := pointer.pointer_new(name)!
	if ptr.chapter != '' && ptr.chapter != chapter.name {
		return error("Can't get in chapter, chapter name asked for is ${ptr.chapter} while we are in chaptner ${chapter.name}")
	}
	if ptr.name in chapter.files {
		return chapter.files[ptr.name] or {
			return ChapterObjNotFound{
				cat: cat
				chapter: chapter.name
				name: ptr.name
			}
		}
	}
	return ChapterObjNotFound{
		cat: cat
		chapter: chapter.name
		name: ptr.name
	}
}

pub fn (mut chapter Chapter) image_get(name string) !&File {
	cat := 'image'
	ptr := pointer.pointer_new(name)!
	if ptr.chapter != '' && ptr.chapter != chapter.name {
		return error("Can't get in chapter, chapter name asked for is ${ptr.chapter} while we are in chaptner ${chapter.name}")
	}
	if ptr.name in chapter.images {
		return chapter.images[ptr.name] or {
			return ChapterObjNotFound{
				cat: cat
				chapter: chapter.name
				name: ptr.name
			}
		}
	}
	return ChapterObjNotFound{
		cat: cat
		chapter: chapter.name
		name: ptr.name
	}
}

pub fn (mut chapter Chapter) page_exists(name string) bool {
	_ := chapter.page_get(name) or {
		if err is ChapterObjNotFound {
			return false
		} else {
			panic(err) // catch unforseen errors
		}
	}
	return true
}

pub fn (mut chapter Chapter) image_exists(name string) bool {
	_ := chapter.image_get(name) or {
		if err is ChapterObjNotFound {
			return false
		} else {
			panic(err)
		}
	}
	return true
}

pub fn (mut chapter Chapter) file_exists(name string) bool {
	_ := chapter.file_get(name) or {
		if err is ChapterObjNotFound {
			return false
		} else {
			panic(err)
		}
	}
	return true
}

///////////////////////////////////////////////////////////

// add a page to the chapter, specify existing path
// the page will be parsed as markdown
pub fn (mut chapter Chapter) page_new(mut p Path) !&Page {
	$if debug {
		println(" - chapter:'${chapter.name}' page new: ${p.path}")
	}
	mut ptr := pointer.pointerpath_new(path: p.path, path_normalize: true, needs_to_exist: true)!
	mut doc := markdowndocs.new(path: p.path) or { panic('cannot parse,${err}') }
	mut page := Page{
		doc: &doc
		pathrel: p.path_relative(chapter.path.path)!.trim('/')
		name: ptr.pointer.name
		path: p
		chapter: &chapter
		readonly: false
	}
	chapter.pages[ptr.pointer.name] = &page
	return chapter.pages[ptr.pointer.name] or {
		return error('Cannot find page ${ptr.pointer.name} in chapter: ${chapter.name}')
	}
}

// add a file to the chapter, specify existing path
pub fn (mut chapter Chapter) file_new(mut p Path) ! {
	$if debug {
		println(" - chapter:'${chapter.name}' file new: ${p.path}")
	}
	mut ptr := pointer.pointerpath_new(path: p.path, path_normalize: true, needs_to_exist: true)!
	mut ff := File{
		path: p
		chapter: &chapter
	}
	ff.init()
	chapter.files[ptr.pointer.name] = &ff
}

// add a image to the chapter, specify existing path
pub fn (mut chapter Chapter) image_new(mut p Path) ! {
	$if debug {
		println(" - chapter:'${chapter.name}' image new: ${p.path}")
	}

	mut ptr := pointer.pointerpath_new(path: p.path, path_normalize: true, needs_to_exist: true)!
	if ptr.pointer.name.starts_with('.') {
		panic('should not start with . \n${p}')
	}
	if chapter.image_exists(ptr.pointer.name) {
		// TODO: fix doubles

		// remove this one
		// mut file_double := chapter.image_get(p.name())!
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
		chapter: &chapter
	}
	ff.init()
	chapter.images[ptr.pointer.name] = &ff
}

// go over all pages, fix the links, check the images are there
pub fn (mut chapter Chapter) fix() ! {
	$if debug {
		println(' --- chapter fix: ${chapter.name}')
	}
	for _, mut page in chapter.pages {
		page.fix()!
	}
	chapter.errors_report()!
}

// return all pagenames for a chapter
pub fn (mut chapter Chapter) pagenames() []string {
	mut res := []string{}
	for key, _ in chapter.pages {
		res << key
	}
	res.sort()
	return res
}

// write errors.md in the chapter, this allows us to see what the errors are
pub fn (mut chapter Chapter) errors_report() ! {
	mut p := pathlib.get('${chapter.path.path}/errors.md')
	if chapter.errors.len == 0 {
		p.delete()!
		return
	}
	c := $tmpl('template/errors_chapter.md')
	p.write(c)!
}
