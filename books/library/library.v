module library
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.gittools

[heap]
pub struct Library {
pub mut:
	books map[string]&Book
	state LibraryState
}

pub enum LibraryState{
	init
	ok 
	error
}

[params]
pub struct BookNewArgs{
pub mut:
	name string
	chapters_path string
	chapters_giturl string
	git_reset bool
	git_root  string
	git_pull  bool
	heal      bool // healing means we fix images, if selected will automatically load, remove stale links
	load      bool	
}

pub fn (mut l Library) book_new(args_ BookNewArgs)!&Book{
	mut args:=args_
	args.name=texttools.name_fix_no_underscore_no_ext(args.name)
	if args.name==""{
		return error("Cannot specify new book without specifying a name.")
	}

	mut b:=Book{name:args.name,library:&l}
	l.books[args.name]=&b

	if args.chapters_giturl.len > 0 {
		mut gs := gittools.get(root: args.git_root)!
		mut gr := gs.repo_get_from_url(url: args.chapters_giturl, pull: args.git_pull, reset: args.git_reset)!
		args.chapters_path = gr.path_content_get()
	}

	if args.chapters_path.len>0{
		b.scan_recursive(path:args.chapters_path, heal:args.heal, load:args.load)!
	}	

	return l.books[args.name] or {panic("bug")}
}


pub struct BookNotFound {
	Error
pub:
	bookname string
	library &Library
	msg string
}
pub fn (library Library) booknames() []string {
	mut res := []string{}
	for _,book in library.books {
		res << book.name
	}
	res.sort()
	return res
}


pub fn (err BookNotFound) msg() string {
	booknames := err.library.booknames().join('\n- ')
	if err.msg.len>0{
		return err.msg
	}
	return "Cannot not find book:'${err.bookname}'.\nKnown books:\n${booknames}"
}



pub fn ( library Library) book_get(name string) !&Book {
	if name.contains(":"){
		return BookNotFound{
			library:&library
			msg: "bookname cannot have : inside"
			bookname:name
		}
	}
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	if namelower==""{
		return BookNotFound{
			library:&library
			msg:'book needs to be specified, now empty.'
		}		
	}	
	return library.books[namelower] or {
		return BookNotFound{
			library:&library
			bookname:name
		}
	}
}

pub fn ( library Library) book_exists(name string) bool {
	_ := library.book_get(name) or {
		if err is BookNotFound  {
			return false
		} else {
			panic(err) // catch unforseen errors
		}
	}
	return true
}


// fix all loaded library
pub fn (mut library Library) fix() ! {
	if library.state == .ok {
		return
	}
	for _, mut book in library.books {
		book.fix()!
	}
}


// get the page from a pointer, format of pointer is $book:$chapter:$name or $book::$name 
pub fn ( library Library) page_get(pointerstr string) !&Page {
	p:=pointer_new(pointerstr)!
	mut book := library.book_get(p.book)!
	return book.page_get(pointerstr)!
}

// get the image from a pointer, format of pointer is $book:$chapter:$name or $book::$name 
pub fn ( library Library) image_get(pointerstr string) !&File {
	p:=pointer_new(pointerstr)!
	mut book := library.book_get(p.book)!
	return book.image_get(pointerstr)!
}

// get the file from a pointer, format of pointer is $book:$chapter:$name or $book::$name 
pub fn ( library Library) file_get(pointerstr string) !&File {
	p:=pointer_new(pointerstr)!
	mut book := library.book_get(p.book)!
	return book.file_get(pointerstr)!
}

// get the image from a pointer, format of pointer is $book:$chapter:$name or $book::$name 
pub fn ( library Library) page_exists(pointerstr string) bool {
	_ := library.page_get(pointerstr) or {
		if err is ChapterNotFound || err is ChapterObjNotFound || err is BookNotFound || err is NoOrTooManyObjFound{
			return false
		} else {
			panic(err) // catch unforseen errors
		}
	}
	return true
}


// get the image from a pointer, format of pointer is $book:$chapter:$name or $book::$name 
pub fn ( library Library) image_exists(pointerstr string) bool {
	_ := library.image_get(pointerstr) or {
		if err is ChapterNotFound || err is ChapterObjNotFound || err is BookNotFound || err is NoOrTooManyObjFound{
			return false
		} else {
			panic(err) // catch unforseen errors
		}
	}
	return true
}

// get the image from a pointer, format of pointer is $book:$chapter:$name or $book::$name 
pub fn ( library Library) file_exists(pointerstr string) bool {
	_ := library.file_get(pointerstr) or {
		if err is ChapterNotFound || err is ChapterObjNotFound || err is BookNotFound || err is NoOrTooManyObjFound{
			return false
		} else {
			panic(err) // catch unforseen errors
		}
	}
	return true
}
