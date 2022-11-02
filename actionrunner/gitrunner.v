module actionrunner

import freeflowuniverse.crystallib.actionparser { Action }
import freeflowuniverse.crystallib.gittools { GitStructure }

struct GitRunner {
	channel chan ActionMessage
mut:
	gt GitStructure
}

pub fn new_gitrunner() &GitRunner {
	mut gt := gittools.get(root: '') or { panic("Can't get gittools: $err") }
	mut runner := GitRunner{
		gt: gt
	}
	return &runner
}

fn (mut runner GitRunner) run() {
	mut msg := ActionMessage{}
	for {
		msg = <-runner.channel
		mut action := Action{
			name: msg.name
			params: msg.params
		}
		match action.name {
			'git.params.multibranch' { runner.run_multibranch(mut action) }
			'git.pull' { runner.run_pull(mut action) }
			'git.link' { runner.run_link(mut action) }
			else { panic('Gitrunner received unhandled action') }
		}
	}
}

fn (mut runner GitRunner) run_pull(mut action Action) {
	// TODO: if local repo is at local branch that has no upstream produces following error
	// ! 'Your configuration specifies to merge with the ref 'refs/heads/branch'from the remote, but no such ref was fetched.
	url := action.params.get('url') or { panic("Couldn't get params") }
	name := action.params.get_default('url', '') or { panic("Couldn't get params") }
	$if debug {
		eprintln(@FN + ': git pull: $url')
	}
	mut repo := runner.gt.repo_get_from_url(url: url, name: name) or {
		panic('Could not get repo from url: $err')
	}
	repo.pull() or { panic('Could not pull repo: $err') }
	Runner(runner).action_complete(action)
}

fn (mut runner GitRunner) run_link(mut action Action) {
	//? Maybe we can have one src and dest field to simplify?
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
	runner.gt.link(gitlinkargs) or { panic('Could not link: $err') }
	Runner(runner).action_complete(action)
}

fn (mut runner GitRunner) run_multibranch(mut action Action) {
	$if debug {
		eprintln(@FN + ': multibranch set')
	}
	runner.gt.config.multibranch = true
	Runner(runner).action_complete(action)
}
