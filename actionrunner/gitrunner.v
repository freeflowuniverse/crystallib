module actionrunner

import freeflowuniverse.crystallib.actionparser { Action }
import freeflowuniverse.crystallib.gittools {GitStructure}

struct GitRunner {
mut:
	channel chan ActionMessage
}

pub fn new_gitrunner() Runner {
	mut runner := Runner(GitRunner{})
	return runner
}

fn (runner GitRunner) run()? {
	mut action := ActionMessage{}
	mut gt := gittools.get(root: '') or { panic("Can't get gittools: $err")}
	for {
		action = <- runner.channel
		match action.name {
			'git.params.multibranch' {
				$if debug {
					eprintln(@FN + ': multibranch set')
				}
				gt.config.multibranch = true
				Runner(runner).action_complete(action)
			}
			'git.pull' {
				// TODO: if local repo is at local branch that has no upstream produces following error
				// ! 'Your configuration specifies to merge with the ref 'refs/heads/branch'from the remote, but no such ref was fetched.
				url := action.params.get('url')?
				name := action.params.get_default('url', '')?
				$if debug {
					eprintln(@FN + ': git pull: $url')
				}
				mut repo := gt.repo_get_from_url(url: url, name: name)?
				repo.pull()?
				Runner(runner).action_complete(action)
			}
			//? Maybe we can have one src and dest field to simplify?
			'git.link' {
				// struct GitLinkArgs {
				// 	gitsource string   // the name of the git repo as used in gittools from the source
				// 	gitdest string		//same but for destination
				// 	source string		//if gitsource used, then will be append to the gitsource repo path
				// 	dest string			//if gitdest used, then will be append to the gitfest repo path, to see where link is created
				// 	pull bool			//means we will pull source & destination
				// 	reset bool			//means we will reset changes, they will be overwritten
				// }
				println('params: $action.params')
				gitlinkargs := gittools.GitLinkArgs{
					gitsource: action.params.get_default('gitsource', '') or { panic("Can't get param") }
					gitdest: action.params.get_default('gitdest', '') or { panic("Can't get param") }
					source: action.params.get('source') or { panic("Can't get param") }
					dest: action.params.get('dest') or { panic("Can't get param") }
					pull: action.params.get_default_false('pull')
					reset: action.params.get_default_false('reset')
				}

				$if debug {
					eprintln(@FN + gitlinkargs.str())
				}
				gt.link(gitlinkargs)?
				Runner(runner).action_complete(action)
			}
			else { panic("Gitrunner received unhandled action") }
		}
	}
}
