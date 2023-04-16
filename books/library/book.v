module library

import freeflowuniverse.crystallib.books.textools

[heap]
pub struct Book {
pub mut:
	chapters map[string]&chapter.Chapter
	library &Library
}

pub fn (mut book Book) chapter_exists(name string) bool {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	if  namelower in library.chapters {
		return true
	}
	return false
}

pub fn (mut book Book) chapter_get(name string) !&Chapter {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	for key,ch in library.chapters {
		if key==namelower{
			return ch
		}
	}
	return error('could not find chapter with name:${name}')
}

// fix all loaded library
pub fn (mut book Book) fix() ! {
	if library.state == .ok {
		return
	}
	for key, mut ch in library.chapters {
		ch.fix()!
	}
}

pub fn (mut book Book) chapternames() []string {
	mut res := []string{}
	for ke,chapter in library.chapters {
		res << chapter.name
	}
	res.sort()
	return res
}


// internal function
fn (mut book Book) chapter_get_from_pointer(p pointer.Pointer) !&Chapter {
	if p.chapter in library.library {
		// means chapter exists
		mut ch := library.library[p.chapter] or { panic('cannot find ${p.chapter}') }
		return ch
	}
	chapternames := library.chapternames().join('\n- ')
	msg := 'Cannot find chapter with name:${p.chapter} \nKnown chapter names are:\n\n${chapternames}'
	return error(msg)
}

pub fn (mut book Book) chapter_get(name string) !&Chapter {
	p:=pointer.pointer_new(name)
	return library.chapter_get_from_pointer(p)!
}


// get the page
pub fn (mut book Book) page_get(name string) !&Page {
	p:=pointer.pointer_new(name)
	mut chapter := library.chapter_get_from_pointer(p)!
	return chapter.page_get(name)!
}

// get the image
pub fn (mut book Book) image_get(name string) !&File {
	p:=pointer.pointer_new(name)
	mut chapter := library.chapter_get_from_pointer(p)!
	return chapter.image_get(name)!
}

// get the file
// the chapter name needs to be specified
pub fn (mut book Book) file_get(name string) !&File {
	p:=pointer.pointer_new(name)
	mut chapter := library.chapter_get_from_pointer(name)!
	return chapter.file_get(name)!
}

// will walk over all library, untill it finds the image or the file
pub fn (mut book Book) image_file_find_over_sites(name string) !&File {
	for _, mut chapter in library.library {
		if chapter.image_exists(name) {
			return chapter.image_get(name)
		}
		if chapter.file_exists(name) {
			return chapter.file_get(name)
		}
	}
	return error('could not find image over all chapters: ${name} in book: ${book.name}')
}


