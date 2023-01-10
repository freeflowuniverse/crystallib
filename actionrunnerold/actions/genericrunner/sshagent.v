module actions

import sshagent
import freeflowuniverse.crystallib.actionparser { Action }
import freeflowuniverse.crystallib.actionparser { Action }


fn (mut runner Runner) sshagent_load_single_key(mut job ActionJob)! {
	// TODO: if local repo is at local branch that has no upstream produces following error
	// ! 'Your configuration specifies to merge with the ref 'refs/heads/branch'from the remote, but no such ref was fetched.
	url := action.params.get('url') or { return error("Couldn't get url.\n$err") }
	name := action.params.get_default('name', '') or { return error("Couldn't get params name.\n$err") }
	$if debug {
		eprintln(@FN + ': git pull: $url')
	}
	mut repo := runner.gt.repo_get_from_url(url: url, name: name) or {
		return error('Could not get repo from url $url\n$err')
	}
	repo.pull() or { return error('Could not pull repo $url\n$err') }
	Runner(runner).action_complete(action)
}

fn (mut runner )action_process(mut job ActionJob , actions_done map[string]string) !map[string]string {

	book_name := action.params.get_default('name', '') or { panic("Can't get name param: $err") }
	sshagent.key_load_single()!

	return actions_done
}



