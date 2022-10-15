module books

// import os
import freeflowuniverse.crystallib.pathlib { Path }
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.markdowndocs

enum BookType {
	book
	wiki
	web
}

enum BookState {
	init
	initdone
	scanned
	fixed
	ok
}

[heap]
pub struct Book {
pub:
	name     string
	booktype BookType
pub mut:
	title  string
	books  &Books           [str: skip] // pointer to books
	pages  map[string]&Page
	files  map[string]&File
	path   Path
	errors []BookError
	book   BookState
}

//load the Summary
pub fn (mut book Book) load() ? {
	// content:=book.path.read()?
	mut summarypath:=book.path.path+"/summary.md"
	mut parser := markdowndocs.get(summarypath) or { panic('cannot book parse $summarypath ,$err') }

	for mut item in parser.doc.items.filter(it is markdowndocs.Paragraph) {
		if mut item is markdowndocs.Paragraph {
			for mut link in item.links {
				if link.isexternal {
					panic("external link not supported yet in \n$book")
				} else { 
					$if debug{
						println(" -- book link: $link")
					}
					panic(link)
				}
			}
		}
	}
}


enum BookErrorCat {
	unknown
	file_not_found
	page_not_found
	sidebar
}

struct BookErrorArgs {
	msg  string
	cat  BookErrorCat
}

struct BookError {
	msg  string
	cat  BookErrorCat
}

pub fn (mut book Book) error(args BookErrorArgs) {
	book.errors << BookError{
		msg: args.msg
		cat: args.cat
	}
}

pub fn (mut book Book) fix() ? {
}

// return path where the book will be created (exported and built from)
pub fn (book Book) book_path(path string) Path {
	dest0 := book.books.config.dest
	return pathlib.get('$dest0/books/$book.name/$path')
}

// return path where the book will be created (exported and built from)
pub fn (book Book) html_path(path string) Path {
	dest0 := book.books.config.dest
	return pathlib.get('$dest0/html/$book.name/$path')
}


// export an mdbook to its html representation
pub fn (mut book Book) mdbook_export() ? {
	book.template_install()? // make sure all required template files are in site
	dest := book.books.config.dest
	book_path := book.book_path().path
	html_path := book.html_path().path

	// lets now walk over images & pages and we need to export it to there
	if true{
		panic("TODO implement mdbook export")
	}

	// lets now build
	os.execute('mdbook build $book_path --dest-dir $html_path')
}


fn (mut book Book) template_write(path string, content string) ? {
	mut dest_path := book.book_path(path)
	dest_path.write(content)?
}

fn (mut book Book) template_install() ? {
	if book.title == '' {
		book.title = book.name
	}

	// get embedded files to the mdbook dir
	for item in site.sites.embedded_files {
		book_path := item.path.all_after_first('/')
		site.template_write(book_path, item.to_string())?
	}
	c := $tmpl('template/book.toml')
	site.template_write('book.toml', c)?
}
