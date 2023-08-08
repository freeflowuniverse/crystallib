module knowledgetree

import freeflowuniverse.crystallib.gittools

// TODO: need to get this to work, needs basic tooling to be able to use 3script

// ! Use booksrunner in ./actionrunner

import freeflowuniverse.crystallib.actions

import os

// QUESTION: can you write specs for this function, what should it do, what actions should it recognize, please be specific
// find all actions & process, this works inclusive
pub fn actions_process(mut parser actions.Actions, actions_done map[string]string) !map[string]string {
	// $if debug {
	// 	println("+++++")
	// 	println(actions)
	// 	println("-----")
	// }

	mut tree := new()!

	//sites.scan(path + '/content')?
	tree.scan(path: os.getwd())!

	mut gt := gittools.get()!

	for mut action in parser.actions {
		$if debug {
			println(' --------ACTION BOOKS:\n$action\n--------')
		}

		if action.name == 'books.add' {
			book_url := action.params.get('url')!
			book_name := action.params.get_default('name', '')!
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
			)!
			book_path := gr.path_content_get()
			tree.book_new(path: book_path, name: book_name)!
		}

		if action.name == 'books.mdbook_develop' {
			tree.scan()!
			name := action.params.get('name')!
			mut book := tree.book_get(name)!
			// QUESTION: I can't find any mdbook_develop function nor develop function, what is this function and what should it do?
			//book.mdbook_develop()!
		}

		//? Currently can only export book by name, is that ok?
		if action.name == 'books.mdbook_export' {
			tree.scan()!
			name := action.params.get('name')!
			dest_path := action.params.get('path')!

			mut book := tree.book_get(name)!
			//? What do book_pull and book_reset do?
			// mut gr := gt.repo_get_from_url(url: export_url, pull: book_pull, reset: book_reset)?
			// mut export_repo := gt.repo_get_from_url(url: export_url)?
			// export_path := export_repo.path_content_get()
			//site := tree.site_new(path: book.path.path)!
			//site.export(dest_path)!
			// QUESTION: the code above doesn't seem to exist, I could only find export for the MDBook object
			book.export()!
		}
	}
	return actions_done
}
