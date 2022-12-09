module actionrunner

import freeflowuniverse.crystallib.gittools { GitStructure, GitRepo }
import freeflowuniverse.crystallib.params { Params }
import freeflowuniverse.crystallib.sshagent

struct GitRunner {
	Runner
mut:
	gt GitStructure [str: skip] 
}

pub fn new_gitrunner() &GitRunner {
	// doesn't use factory since git init might specify separate config
	mut gt := GitStructure{}
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
	// used to initialize gitstructure by default
	// if git init action isn't the first job
	mut first_job := true

	mut job := &ActionJob{}
	for {

		// currentjob buffer only has 1 job at a time
		if runner.jobcurrent.len == 0 {
			job = <- runner.channel
			runner.jobcurrent << job
		}

		// initialize gitstructure by default
		if first_job && job.actionname != 'git.init' {
			runner.gt = gittools.get(root: '') or { panic("Can't get gittools: $err") }
			first_job = false
		}

		runner.running()
		match runner.jobcurrent[0].actionname {
			'git.init' { runner.run_init(mut job) or {runner.error("$err")} }
			'git.params.multibranch' { runner.run_multibranch() or {runner.error("$err")} }
			'git.get' { runner.run_get(mut job) or {runner.error("$err")}}
			'git.link' { runner.run_link(mut job) or {runner.error("$err")}}
			'git.commit' { runner.run_commit(mut job) or {runner.error("$err")}}
			else { 					
				runner.error("could not find action for job:\n$job")
			}
		}
		runner.done()
	}
}

fn (mut runner GitRunner) run_init(mut job ActionJob)! {

	path := job.params.get('path') or { '' }
	multibranch := job.params.get('multibranch') or { '' }

	runner.gt = gittools.get(root: path, multibranch: multibranch == 'true') or { panic("Can't get gittools: $err") }
}

fn (mut runner GitRunner) run_get(mut job ActionJob)! {
	// TODO: if local repo is at local branch that has no upstream produces following error
	// ! 'Your configuration specifies to merge with the ref 'refs/heads/branch'from the remote, but no such ref was fetched.
	if !sshagent.loaded() {
		return error('ssh key must be loaded')
	}
	url := job.params.get('url') or { return error("Couldn't get url.\n$err") }
	
	name := job.params.get_default('name', '') or { return error("Couldn't get params name.\n$err") }
	$if debug {
		eprintln(@FN + ': git pull: $url')
	}
	mut repo := runner.gt.repo_get_from_url(url: url, name: name) or {
		return error('Could not get repo from url $url\n$err')
	}
	repo.pull() or { return error('Could not pull repo $url\n$err') }
}

fn (mut runner GitRunner) run_link(mut job ActionJob) !{
	gitlinkargs := gittools.GitLinkArgs{
		gitsource: job.params.get_default('gitsource', '') or { panic("Can't get param") }
		gitdest: job.params.get_default('gitdest', '') or { panic("Can't get param") }
		source: job.params.get('source') or { '' }
		dest: job.params.get('dest') or { '' }
		pull: job.params.get_default_false('pull')
		reset: job.params.get_default_false('reset')
	}

	runner.gt.link(gitlinkargs) or { return error('Could not link \n$gitlinkargs\n$err') }
}

fn (mut runner GitRunner) run_commit(mut job ActionJob) !{

	url := job.params.get('url') or { '' } 
	name := job.params.get_default('name', '') or { '' }
	msg := job.params.get('message') or { return error('message cannot be empty') }
	push := job.params.get_default('push', '') or { '' }

	// get repository from url or name
	mut repo := GitRepo{}
	if url != '' {
		repo = runner.gt.repo_get_from_url(url: url, name: name) or {
			return error('Could not get repo from url $url\n$err')
		} 
	} else if name != '' {
		repo = runner.gt.repo_get(name: name) or {
			return error('Could not get repo from name $name\n$err')
		} 
	} else {
		return error("Can't get repo without name or url") 
	}

	repo.commit(msg) or { return error('Could not commit repo $repo\n$err') }
	if push == 'true' {
		repo.push() or { return error('Could not push repo $repo\n$err') }
	}
}

fn (mut runner GitRunner) run_multibranch()! {
	runner.gt.config.multibranch = true	
	runner.log(@FN + ': multibranch set')
	$if debug {
		runner.log("running multibranch")
	}	
}

fn (mut runner GitRunner) run_repo_delete()! {
	runner.gt.config.multibranch = true	
	runner.log(@FN + ': multibranch set')
	$if debug {
		runner.log("running multibranch")
	}	
}

