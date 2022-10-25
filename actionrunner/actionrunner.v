module actionrunner

import freeflowuniverse.crystallib.gittools
import freeflowuniverse.crystallib.actionparser

// find all actions & process, this works inclusive
fn actions_process(mut parser actionparser.ActionsParser, actions_done map[string]string) ?map[string]string {
	// $if debug {
	// 	println("+++++")
	// 	println(actions)
	// 	println("-----")
	// }
	// go to default structure on ~/code
	mut gt := gittools.get(root: '')?

	for mut action in parser.actions {
		$if debug {
			println(' --------ACTION:\n$action\n--------')
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
	}
	return actions_done
}
