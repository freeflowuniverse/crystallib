module books

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.params
import freeflowuniverse.crystallib.installers.mdbook
import v.embed_file
import freeflowuniverse.crystallib.markdowndocs

enum BooksState {
	init
	initdone
	ok
}

[heap]
pub struct BooksConfig {
pub mut:
	heal bool   = true
	dest string = '/tmp/mdbooks'
}

[heap]
pub struct Books {
pub mut:
	books          map[string]&Book
	sites          &Sites                     [str: skip] // pointer to sites
	state          BooksState
	embedded_files []embed_file.EmbedFileData // this where we have the templates for exporting a book
	config         BooksConfig
}

pub struct BookNewArgs {
	name string
	path string
}

// add a book to the book collection
// 		name string
// 		path string
pub fn (mut books Books) book_new(args BookNewArgs) !&Book {
	mut p := pathlib.get_file(args.path, false)! // makes sure we have the right path
	if !p.exists() {
		return error('cannot find book on path: ${args.path}')
	}
	p.path_normalize()! // make sure its all lower case and name is proper
	mut name := args.name
	if name == '' {
		name = p.name()
	}

	// is case insensitive
	//? checks for both summary.md files and links
	mut summarypath := p.file_get('summary.md') or {
		p.link_get('summary.md') or { return error('cannot find summary path: ${err}') }
	}
	mut doc := markdowndocs.get(summarypath.path) or {
		panic('cannot book parse ${summarypath} ,${err}')
	}

	mut book := Book{
		name: texttools.name_fix_no_ext(name)
		path: p
		books: &books
		doc_summary: &doc
	}

	books.books[book.name.replace('_', '')] = &book
	return &book
}

fn (mut books Books) scan_recursive(mut path pathlib.Path) ! {
	books.init()!
	// $if debug{println(" - books scan recursive: $path.path")}
	if path.is_dir() {
		if path.file_exists('.book') {
			mut name := path.name()
			mut bookfilepath := path.file_get('.book')!
			// now we found a book we need to add
			content := bookfilepath.read()!
			if content.trim_space() != '' {
				// means there are params in there
				mut params_ := params.parse(content)!
				if params_.exists('name') {
					name = params_.get('name')!
				}
			}
			println(' - book new: ${path.path} name:${name}')
			books.book_new(path: path.path, name: name)!
			return
		}
		mut llist := path.list(recursive: false) or {
			return error('cannot list: ${path.path} \n${error}')
		}
		for mut p_in in llist {
			if p_in.is_dir() {
				if p_in.path.starts_with('.') || p_in.path.starts_with('_') {
					continue
				}

				books.scan_recursive(mut p_in) or {
					msg := 'Cannot process recursive on ${p_in.path}\n${err}'
					// println(msg)
					return error(msg)
				}
			}
		}
	}
}

pub fn (mut books Books) scan(path string) ! {
	mut p := pathlib.get_dir(path, false)!
	books.scan_recursive(mut p)!
	books.fix()!
}

pub fn (mut books Books) get(name string) !&Book {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	if namelower in books.books {
		return books.books[namelower]
	}
	return error('could not find book with name:${name}')
}

// fix all loaded books
pub fn (mut books Books) fix() ! {
	if books.state == .ok {
		return
	}
	for _, mut site in books.sites.sites {
		site.fix()!
	}
	for _, mut book in books.books {
		book.fix()!
	}
	books.state = .ok
}

// make sure all initialization has been done e.g. installing mdbook
pub fn (mut books Books) init() ! {
	if books.state == .init {
		mdbook.install()!
		books.embedded_files << $embed_file('template/theme/css/print.css')
		books.embedded_files << $embed_file('template/theme/css/variables.css')
		books.embedded_files << $embed_file('template/mermaid-init.js')
		books.embedded_files << $embed_file('template/mermaid.min.js')

		books.state = .initdone
	}
}

// reset all, just to make sure we regenerate fresh
pub fn (mut books Books) reset() ! {
	// delete where the books are created
	for item in ['books', 'html'] {
		mut a := pathlib.get(books.config.dest + '/${item}')
		a.delete()!
	}
	books.state = .init // makes sure we re-init
	books.init()!
}

// export the mdbooks to html
pub fn (mut books Books) mdbook_export() ! {
	books.reset()! // make sure we start from scratch
	books.fix()!
	for _, mut book in books.books {
		book.mdbook_export()!
	}
}
