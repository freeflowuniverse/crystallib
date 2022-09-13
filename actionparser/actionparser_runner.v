module actionparser

import freeflowuniverse.crystallib.gittools
import freeflowuniverse.crystallib.books

// find all actions & process, this works inclusive
fn (mut parser ActionsParser) actions_process() ?[]string {
	// $if debug {
	// 	println("+++++")
	// 	println(actions)
	// 	println("-----")
	// }
	mut actions_done := []string{}

	// go to default structure on ~/code
	mut gt := gittools.get(root: '')?

	mut books := books.new()

	for mut action in parser.actions {
		$if debug {
			println(' --------ACTION:\n$action\n--------')
		}

		// recursive behavior, include other files and also process
		if action.name == 'include' {
			path := action.params.get_path('path')? // will also check path exists
			mut ap := file_parse(path)?
			ap.actions_process()?
			actions_done << 'include $path'
		}

		if action.name == 'git.params.multibranch' {
			$if debug {
				eprintln(@FN + ': multibranch set')
			}
			gt.config.multibranch = true
		}

		// TODO: if local repo is at local branch that has no upstream produces following error
		// ! 'Your configuration specifies to merge with the ref 'refs/heads/branch'from the remote, but no such ref was fetched.
		if action.name == 'git.pull' {
			url := action.params.get('url')?
			name := action.params.get_default('url', '')?
			$if debug {
				eprintln(@FN + ': git pull: $url')
			}
			mut repo := gt.repo_get_from_url(url: url, name: name)?
			repo.pull()?
		}

		// struct GitLinkArgs {
		// 	gitsource string   // the name of the git repo as used in gittools from the source
		// 	gitdest string		//same but for destination
		// 	source string		//if gitsource used, then will be append to the gitsource repo path
		// 	dest string			//if gitdest used, then will be append to the gitfest repo path, to see where link is created
		// 	pull bool			//means we will pull source & destination
		// 	reset bool			//means we will reset changes, they will be overwritten
		// }
		//? Maybe we can have one src and dest field to simplify?
		if action.name == 'git.link' {
			gitlinkargs := gittools.GitLinkArgs{
				gitsource: action.params.get_default('gitsource', '')?
				gitdest: action.params.get_default('gitdest', '')?
				source: action.params.get('source')?
				dest: action.params.get('dest')?
				pull: action.params.get_default_false('pull')
				reset: action.params.get_default_false('reset')
			}
			$if debug {
				eprintln(@FN + gitlinkargs.str())
			}
			gt.link(gitlinkargs)?
		}

		if action.name == 'books.add' {
			book_url := action.params.get('url')?
			book_name := action.params.get_default('name', '')?
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
			)?
			book_path := gr.path_content_get()
			books.site_new(path: book_path, name: book_name)?
		}

		if action.name == 'books.mdbook_develop' {
			books.scan()?
			name := action.params.get('name')?
			mut book := books.get(name)?
			book.mdbook_develop()?
		}

		//? Currently can only export book by name, is that ok?
		if action.name == 'books.mdbook_export' {
		 	books.scan()?
		 	name := action.params.get('name')?
		 	dest_path := action.params.get('path')?
			
			mut book := books.get(name)?
			//? What do book_pull and book_reset do?
		 	//mut gr := gt.repo_get_from_url(url: export_url, pull: book_pull, reset: book_reset)?
		 	//mut export_repo := gt.repo_get_from_url(url: export_url)?
		 	//export_path := export_repo.path_content_get()
			site := books.site_new(path: book.path.path)?
			site.mdbook_export(dest_path) ?
		}

	}
	return actions_done
}
