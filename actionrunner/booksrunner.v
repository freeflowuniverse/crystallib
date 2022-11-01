module actionrunner

import freeflowuniverse.crystallib.actionparser {Action}
import freeflowuniverse.crystallib.books {books_new}
import freeflowuniverse.crystallib.gittools {GitStructure}

struct BooksRunner {
	channel chan ActionMessage
}

pub fn new_booksrunner() BooksRunner{
	runner := BooksRunner{}
	return runner
}

fn (mut runner BooksRunner) run()! {

	mut action := ActionMessage{}
	mut sites := books.sites_new()
	mut gt := gittools.get(root: '') or { panic('Cannot get git: $err') }
	mut books := books.books_new(&sites)	
	
	// sites.scan(path + '/content')?
	// books.scan(path + '/books')?

	for {
		action = <- runner.channel
		$if debug {
			println(' --------ACTION BOOKS:\n$action\n--------')
		}
		match action.name {
			'books.add' {
				book_url := action.params.get('url') or { panic("Can't get url param: $err") }
				book_name := action.params.get_default('name', '') or { panic("Can't get name param: $err") }
				book_pull := action.params.get_default_false('pull')
				book_reset := action.params.get_default_false('reset')
				$if debug {
					eprintln(@FN + ': books add pull: $book_url')
				}
				mut gr := gt.repo_get_from_url(
					url: book_url
					pull: book_pull
					reset: book_reset
					name: book_name
				) or { panic("Can't get repo from url: $err") }
				book_path := gr.path_content_get()
				sites.site_new(path: book_path, name: book_name) or { panic("Can't get new site: $err") }
			}
			'books.mdbook_develop' {
				name := action.params.get('name')!
				mut book := books.get(name)!
				books.scan(book.path.path) or {}
				// TODO: book.mdbook_develop()?
			}
			'books.mdbook_export' {
				// TODO: needs to be implemented
				// //? Currently can only export book by name, is that ok?
				// books.scan()?
				// name := action.params.get('name')!
				// dest_path := action.params.get('path')!
				// mut book := books.get(name)?
				// site := sites.site_new(path: book.path.path)?
				// books.mdbook_export(dest_path)?

				//? What do book_pull and book_reset do?
				// mut gr := gt.repo_get_from_url(url: export_url, pull: book_pull, reset: book_reset)?
				// mut export_repo := gt.repo_get_from_url(url: export_url)?
				// export_path := export_repo.path_content_get()
			}
			else {}
		}
	}
}