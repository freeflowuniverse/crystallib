module actionparser


import freeflowuniverse.crystallib.gittools

// find all actions & process, this works inclusive
fn mut (parser ActionsParser) actions_process()?[]string {
	// $if debug {
	// 	println("+++++")
	// 	println(actions)
	// 	println("-----")
	// }
	mut actions_done := []string{}

	mut gt := gittools.get(root: '')?

	for action in parser.actions {
		$if debug {
			println(' --------ACTION:\n$action\n--------')
		}

		// recursive behavior, include other files and also process
		if action.name == 'actions.include' {
			path := action.params.get_path('path')? // will also check path exists
			mut ap := file_parse(path)?
			actions_process(ap)?
			actions_done << 'actions.include $path'
		}

		if action.name == 'git.params.multibranch' {
			$if debug {
				eprintln(@FN + ': multibranch set')
			}
			gt.config.multibranch = true
		}

		if action.name == 'git.pull' {
			url := action.param_get('url')?
			$if debug {
				eprintln(@FN + ': git pull: $url')
			}
			mut repo := gt.repo_get_from_url(url: url)?
			repo.pull()?
		}

		mut books := books.new()

		if action.name == 'books.add' {
			book_url := action.params.get('url')?
			book_pull := action.params.get_default_false('pull')?
			book_reset := action.params.get_default_false('reset')?
			$if debug {
				eprintln(@FN + ': books add pull: $url')
			}
			mut gr := gt.repo_get_from_url(url: book_url, pull: book_pull, reset: book_reset)?
			book_path := gr.path_content_get()

			books.site_new(path: book_path)?

		}

		if action.name == 'books.develop' {
			s.scan()?
			s.develop()?
		}




	return actions_done
}


}