module booksrunner

import freeflowuniverse.crystallib.actionparser
import freeflowuniverse.crystallib.books { books_new }
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.gittools { GitStructure }

struct BooksRunner {
	channel chan ActionJob
mut:
	sites books.Sites
	books books.Books
	gt    GitStructure
}

pub fn new_booksrunner() BooksRunner {
	gt := gittools.get(root: '') or { panic('Cannot get git: ${err}') }
	sites := books.sites_new()
	mut books := books_new(&sites)
	books.init() or { panic("Can't initiate books: ${err}") }
	// sites.scan(path + '/content')?
	// books.scan(path + '/books')?
	runner := BooksRunner{
		sites: sites
		gt: gt
		books: books
	}
	return runner
}

// fn (mut runner BooksRunner) run() {
// 	mut msg := ActionJob{}

// 	for {
// 		msg = <-runner.channel
// 		mut job := Action{
// 			name: msg.name
// 			params: msg.params
// 		}
// 		$if debug {
// 			println(' --------ACTION BOOKS:\n$action\n--------')
// 		}
// 		match action.name {
// 			'books.add' { runner.run_add(mut job) }
// 			'books.mdbook_develop' { runner.run_develop(mut job) }
// 			'books.mdbook_export' { runner.run_export(mut job) }
// 			else {}
// 		}
// 		Runner(runner).action_complete(action)
// 	}
// }

// fn (mut runner BooksRunner) run_add(mut job ActionJob) {
// 	book_name := action.params.get_default('name', '') or { panic("Can't get name param: $err") }
// 	mut book_path := action.params.get('path') or {
// 		panic("Can't get path param: $err \n for action $action")
// 	}
// 	book_pull := action.params.get_default_false('pull')
// 	book_reset := action.params.get_default_false('reset')
// 	mut book_repo := gittools.GitRepo{}

// 	// prepends gitsource to path if exists
// 	// ? should books be added to path by default here?
// 	if action.params.exists('gitsource') {
// 		gitsource := action.params.get_default('gitsource', '') or {
// 			panic("Can't get gitsource param: $err")
// 		}
// 		book_repo = runner.gt.repo_get(name: gitsource) or { panic("Can't get param: $err") }
// 		book_path = book_repo.path + '/books/' + book_path
// 	}

// 	$if debug {
// 		eprintln(@FN + ': books add pull: $book_path')
// 	}
// 	// checks if path param is url or path, uses corresponding repo_get fn
// 	if book_path.starts_with('http') {
// 		book_repo = runner.gt.repo_get_from_url(
// 			url: book_path
// 			pull: book_pull
// 			reset: book_reset
// 			name: book_name
// 		) or { panic("Can't get repo from url: $err") }
// 		book_path = book_repo.path_content_get()
// 	} else {
// 		book_path_obj := pathlib.get(book_path)
// 		book_repo = runner.gt.repo_get_from_path(book_name, book_path_obj, book_pull,
// 			book_reset) or { panic("Can't get repo from url: $err") }
// 	}
// 	runner.books.scan(book_path) or { panic("Can't scan book: $err") }
// 	runner.books.book_new(path: book_path, name: book_name) or { panic("Can't get new book: $err") }
// }

// fn (mut runner BooksRunner) run_develop(mut job ActionJob) {
// 	name := action.params.get('name') or { panic('Cant get params') }
// 	mut book := runner.books.get(name) or { panic('Cant get book: $action \n $runner.sites') }
// 	runner.books.scan(book.path.path) or { panic('Cant scan book: $err') }
// 	// TODO: book.mdbook_develop()?
// }

// fn (mut runner BooksRunner) run_export(mut job ActionJob) {
// 	name := action.params.get('name') or { panic('Cant get params') }
// 	mut book := runner.books.get(name) or { panic('Cant get book: $action \n $runner.sites') }
// 	book.mdbook_export() or { panic('Cant export book: $book \nError: $err') }
// 	// //? Currently can only export book by name, is that ok?
// }
