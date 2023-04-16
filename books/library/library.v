module library
import freeflowuniverse.crystallib.books.textools

[heap]
pub struct Library {
pub mut:
	books map[string]book.Book
}



pub fn (mut library Library) book_exists(name string) bool {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	if  namelower in library.books {
		return true
	}
	return false
}

pub fn (mut library Library) book_get(name string) !&Book {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	for key,book in library.books {
		if key==namelower{
			return book
		}
	}
	return error('could not find book with name:${name}')
}

// fix all loaded library
pub fn (mut library Library) fix() ! {
	if library.state == .ok {
		return
	}
	for key, mut book in library.books {
		book.fix()!
	}
}

pub fn (mut library Library) booknames() []string {
	mut res := []string{}
	for _,book in library.books {
		res << book.name
	}
	res.sort()
	return res
}


// internal function
fn (mut library Library) book_get_from_pointer(p pointer.Pointer) !&Chapter {
	if p.book in library.library {
		// means book exists
		mut book := library.library[p.book] or { panic('cannot find ${p.book}') }
		return book
	}
	booknames := library.booknames().join('\n- ')
	msg := 'Cannot find book with name:${p.book} \nKnown book names are:\n\n${booknames}'
	return error(msg)
}

pub fn (mut library Library) book_get(name string) !&Chapter {
	p:=pointer.pointer_new(name)
	return library.book_get_from_pointer(p)!
}


// get the page
pub fn (mut library Library) page_get(name string) !&Page {
	p:=pointer.pointer_new(name)
	mut book := library.book_get_from_pointer(p)!
	return book.page_get(name)!
}

// get the image
pub fn (mut library Library) image_get(name string) !&File {
	p:=pointer.pointer_new(name)
	mut book := library.book_get_from_pointer(p)!
	return book.image_get(name)!
}

// get the file
// the book name needs to be specified
pub fn (mut library Library) file_get(name string) !&File {
	p:=pointer.pointer_new(name)
	mut book := library.book_get_from_pointer(name)!
	return book.file_get(name)!
}

// will walk over all library, untill it finds the image or the file
pub fn (mut library Library) image_file_find_over_books(name string) !&File {
	for _, mut book in library.books {
		if book.image_exists(name) {
			return book.image_get(name)
		}
		if book.file_exists(name) {
			return book.file_get(name)
		}
	}
	return error('could not find image over all books: ${name} in book: ${book.name}')
}


