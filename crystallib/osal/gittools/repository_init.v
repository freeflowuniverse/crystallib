module gittools

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.tools.sshagent

[params]
pub struct CheckArgs {
pub mut:
	pull  bool
	reset bool
}

// this is the main git functionality to get git repo, update, reset, ...
fn (mut repo GitRepo) init(args_ CheckArgs) ! {
	mut args := args_
	args.pull = args.pull || args.reset

	url := repo.addr.url_http_with_branch_get()
	// println(' - check repo:$url, pull:$args.pull, reset:$args.reset')
	// println(repo.addr)
	// need to get the status of the repo
	// println(' - repo $repo.name() check')
	mut needs_to_be_ssh := false

	// check if there is a custom key to be used (sshkey)
	needs_to_be_ssh0 := repo.ssh_key_load_if_exists()!
	if needs_to_be_ssh0 {
		needs_to_be_ssh = true
	}

	// first check if path does not exist yet, if not need to clone
	if !(repo.path.exists()) {
		println(' - missing repo, pull: ${url} -> ${repo.path.path}')
		if !needs_to_be_ssh && sshagent.loaded() {
			needs_to_be_ssh = true
		}
		// get the url (http or ssh)
		mut cmd := ''
		if needs_to_be_ssh {
			// println("GIT: PULL USING SSH")
			// cmd based on ssh
			cmd = repo.get_clone_cmd(false)
		} else {
			// cmd based on http
			// println("GIT: PULL USING HTTP")
			cmd = repo.get_clone_cmd(true)
		}
		osal.execute_silent(cmd) or {
			println(' GIT FAILED: ${cmd}')
			return error('Cannot pull repo: ${repo.addr.path()}. Error was ${err}')
		}
		// println(' - GIT PULL OK')
		// can return safely, because pull did work		
		repo.load()! //make sure state is ok	
		return
	}

	// check the branch, see if branch on FS is same as what is required if set

	repo.load()!

	if args.reset {
		println(' - remove git changes: ${repo.path.path}')
		repo.remove_changes(reload:false)!
	}

	// println(repo.addr)
	// print_backtrace()
	if repo.addr.branch != '' {
		st := repo.status()!
		mut branchname := st.branch
		// println( " - branch detected: $branchname, branch on repo obj:'$repo.addr.branch'")
		if st.branch != repo.addr.branch && args.pull {
			println(' - branch switch ${branchname} -> ${repo.addr.branch} for ${url}')
			repo.branch_switch(repo.addr.branch)!
			args.pull = true
		}
	} else {
		return error('branch should have been known for ${repo}')
	}
	if args.pull {
		repo.pull()!
	}else{
		repo.load()!
	}
}

fn (repo GitRepo) get_clone_cmd(http bool) string {
	url := repo.url_get(http)
	mut cmd := ''

	mut light := ''
	if repo.gs.config.light {
		light = ' --depth 1 --no-single-branch'
	}

	mut path := repo.addr.path_account()
	// QUESTION: why was branch name used for repo?
	// cmd = 'cd ${path.path} && git clone ${light} ${url} ${repo.addr.branch}'
	cmd = 'cd ${path.path} && git clone ${light} ${url} ${repo.addr.name}'
	if repo.addr.branch != '' {
		cmd += ' -b ${repo.addr.branch}'
	}
	return cmd
}
