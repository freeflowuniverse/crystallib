module actionrunner

import freeflowuniverse.crystallib.gittools { GitStructure }

struct GitRunner {
	Runner
mut:
	gt GitStructure [str: skip] 
}

pub fn new_gitrunner() &GitRunner {
	mut gt := gittools.get(root: '') or { panic("Can't get gittools: $err") }
	mut runner := GitRunner{
		gt: gt
		channel: chan &ActionJob{cap: 100}
		channel_log: chan string{cap: 100}
	}
	return &runner
}

fn (mut runner GitRunner) run() {
	$if debug {
		eprintln('Running gitrunner...')
	}
	mut job := &ActionJob{}
	for {

		// currentjob buffer only has 1 job at a time
		if runner.jobcurrent.len == 0 {
			job = <- runner.channel
			runner.jobcurrent << job
		}

		$if debug {
			eprintln('-- received job: $job.actionname')
		}

		runner.log('running') // set job state to running
		match runner.jobcurrent[0].actionname {
			'git.params.multibranch' { runner.run_multibranch() or {runner.error("$err")} }
			// 'git.pull' { runner.run_pull(mut job) }
			// 'git.link' { runner.run_link(mut job) }
			else { 					
				runner.error("could not find action for job:\n$job")
			}
		}
		// if true{
		// 	panic("runner.channel")
		// }
		runner.done()
	}
}

// fn (mut runner GitRunner) run_pull(mut job ActionJob)! {
// 	// TODO: if local repo is at local branch that has no upstream produces following error
// 	// ! 'Your configuration specifies to merge with the ref 'refs/heads/branch'from the remote, but no such ref was fetched.
// 	url := action.params.get('url') or { return error("Couldn't get url.\n$err") }
// 	name := action.params.get_default('name', '') or { return error("Couldn't get params name.\n$err") }
// 	$if debug {
// 		eprintln(@FN + ': git pull: $url')
// 	}
// 	mut repo := runner.gt.repo_get_from_url(url: url, name: name) or {
// 		return error('Could not get repo from url $url\n$err')
// 	}
// 	repo.pull() or { return error('Could not pull repo $url\n$err') }
// 	Runner(runner).action_complete(action)
// }

// fn (mut runner GitRunner) run_link(mut job ActionJob) !{
// 	//? Maybe we can have one src and dest field to simplify?
// 	// struct GitLinkArgs {
// 	// 	gitsource string   // the name of the git repo as used in gittools from the source
// 	// 	gitdest string		//same but for destination
// 	// 	source string		//if gitsource used, then will be append to the gitsource repo path
// 	// 	dest string			//if gitdest used, then will be append to the gitfest repo path, to see where link is created
// 	// 	pull bool			//means we will pull source & destination
// 	// 	reset bool			//means we will reset changes, they will be overwritten
// 	// }
// 	gitlinkargs := gittools.GitLinkArgs{
// 		gitsource: action.params.get_default('gitsource', '') or { panic("Can't get param") }
// 		gitdest: action.params.get_default('gitdest', '') or { panic("Can't get param") }
// 		source: action.params.get('source') or { panic("Can't get param") }
// 		dest: action.params.get('dest') or { panic("Can't get param") }
// 		pull: action.params.get_default_false('pull')
// 		reset: action.params.get_default_false('reset')
// 	}

// 	$if debug {
// 		eprintln(@FN + gitlinkargs.str())
// 	}
// 	runner.gt.link(gitlinkargs) or { return error('Could not link \n$gitlinkargs\n$err') }
// 	Runner(runner).action_complete(action)
// }

fn (mut runner GitRunner) run_multibranch()! {
	runner.gt.config.multibranch = true	
	// runner.log(@FN + ': multibranch set')
	// $if debug {
	// 	runner.log("running multibranch")
	// }	
}
