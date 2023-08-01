module mdbook

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.gittools
import freeflowuniverse.crystallib.installers.mdbook
import freeflowuniverse.crystallib.books.library
import v.embed_file

enum BooksState {
	init
	initdone
	ok
}

[heap]
pub struct MDBooksConfig {
pub mut:
	heal bool   = true
	dest string = '/tmp/mdbooks'
}

[heap]
pub struct MDBook {
pub mut:
	book           &library.Book
	state          BooksState
	embedded_files []embed_file.EmbedFileData // this where we have the templates for exporting a book
	config         MDBooksConfig
}

[params]
pub struct BookNewArgs {
pub:
	name   string //name of the book
	path   string
	giturl string
	coderoot string //if we want code to be checked out on other location
	codepull bool  //try to pull the code if it already exists
	codereset bool  //reset the code if there is code and newer code is in git
}

// // add a book to the book collection
// // 		name string
// // 		path string
// pub fn book_new(args BookNewArgs) !&Book {

// 	mut path:=args.path

// 	if args.giturl.len>0{
// 		mut gs := gittools.get(root: args.coderoot)!
// 		if args.url<10{
// 			return error("Cannot add book, the path and url not specified. Url was:'$url'")
// 		}

// 		mut gr := gs.repo_get_from_url(url:args.giturl, pull: args.codepull, reset: args.codereset)!

// 		path=gr.path_content_get()

// 		// println(gr)

// 		// this will show the exact path of the manual
// 		println(path)

// 		panic('sdsd')

// 	}

// 	mut p := pathlib.get_file(path, false)! // makes sure we have the right path
// 	if !p.exists() {
// 		return error('cannot find book on path: ${args.path}')
// 	}
// 	p.path_normalize()! // make sure its all lower case and name is proper
// 	mut name := args.name
// 	if name == '' {
// 		name = p.name()
// 	}

// 	// // is case insensitive
// 	// //? checks for both summary.md files and links
// 	// mut summarypath := p.file_get('summary.md') or {
// 	// 	p.link_get('summary.md') or { return error('cannot find summary path: ${err}') }
// 	// }
// 	// mut doc := markdowndocs.new(path: summarypath.path) or {
// 	// 	panic('cannot book parse ${summarypath} ,${err}')
// 	// }

// 	mut book := Book{
// 		name: texttools.name_fix_no_ext(name)
// 		path: p
// 		mdbook: &mdbook
// 		// doc_summary: &doc
// 	}

// 	mdbook.mdbook[book.name.replace('_', '')] = &book
// 	return &book
// }

// // make sure all initialization has been done e.g. installing mdbook
// pub fn (mut mdbook MDBook) init() ! {
// 	if mdbook.state == .init {
// 		mdbook.install()!
// 		mdbook.embedded_files << $embed_file('template/theme/css/print.css')
// 		mdbook.embedded_files << $embed_file('template/theme/css/variables.css')
// 		mdbook.embedded_files << $embed_file('template/mermaid-init.js')
// 		mdbook.embedded_files << $embed_file('template/mermaid.min.js')

// 		mdbook.state = .initdone
// 	}
// }

// // reset all, just to make sure we regenerate fresh
// pub fn (mut mdbook MDBook) reset() ! {
// 	// delete where the mdbook are created
// 	for item in ['mdbook', 'html'] {
// 		mut a := pathlib.get(mdbook.config.dest + '/${item}')
// 		a.delete()!
// 	}
// 	mdbook.state = .init // makes sure we re-init
// 	mdbook.init()!
// }

// // export the mdbooks to html
// pub fn (mut mdbook MDBook) mdbook_export() ! {
// 	mdbook.reset()! // make sure we start from scratch
// 	mdbook.fix()!
// 	for _, mut book in mdbook.mdbook {
// 		// book.mdbook_export()! //TODO: needs to be redone for mdbook
// 	}
// }
