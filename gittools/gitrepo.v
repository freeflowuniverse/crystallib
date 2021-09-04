module gittools

import os
import despiegk.crystallib.process
// import despiegk.crystallib.path


fn (repo GitRepo) path_account_get() string {
	mut gitstructure := gittools.new()
	mut provider := ''
	addr := repo.addr
	if addr.provider == 'github.com' {
		provider = 'github'
	} else {
		provider = addr.provider
	}
	if gitstructure.root == '' {
		panic('cannot be empty')
	}
	return '$gitstructure.root/$provider/$addr.account'
}

pub fn (repo GitRepo) path_content_get() string  {
	mut p := repo.path()
	if repo.addr.path==""{
		return p
	}else{
		return '$p/$repo.addr.path'
	}
	
}

pub fn (repo GitRepo) path() string {
	return repo.path_get()
}

pub fn (repo GitRepo) path_get() string {
	mut gitstructure := gittools.new()
	if gitstructure.multibranch {
		return '$repo.path_account_get()/$repo.addr.name/$repo.addr.branch'
	} else {
		return '$repo.path_account_get()/$repo.addr.name'
	}
}

// if there are changes then will return 'true', otherwise 'false'
pub fn (mut repo GitRepo) changes() ?bool {
	cmd := 'cd $repo.path() && git status'
	out := process.execute_silent(cmd) or {
		return error('Could not execute command to check git status on $repo.path()\ncannot execute $cmd')
	}
	// println(out)
	if out.contains('Untracked files') {
		return true
	} else if out.contains('Your branch is ahead of') {
		return true
	} else if out.contains('Changes not staged for commit') {
		return true
	} else if out.contains('nothing to commit') {
		return false
	} else {
		return true
	}
	// println(out)
	return true
}

fn (mut repo GitRepo) get_clone_cmd(http bool) string {
	mut gitstructure := gittools.new()
	url := repo.url_get(http)
	mut cmd := ''
	if gitstructure.multibranch {
		cmd = 'mkdir -p $repo.path_account_get()/$repo.addr.name && cd $repo.path_account_get()/$repo.addr.name && git clone $url $repo.addr.branch'
	} else {
		cmd = 'mkdir -p $repo.path_account_get() && cd $repo.path_account_get() && git clone $url'
	}
	if repo.addr.branch != '' {
		cmd += ' -b $repo.addr.branch'
	}
	if repo.addr.depth != 0 {
		cmd += ' --depth=$repo.addr.depth'
		//  && cd $repo.addr.name && git fetch
		// why was this there?
	}
	// println(" - CMD: $cmd")
	return cmd
}

// this is the main git functionality to get git repo, update, reset, ...
pub fn (mut repo GitRepo) check(pull_soft_ bool, reset_force_ bool) ? {
	mut pull_soft := pull_soft_ || reset_force_
	mut reset_force := reset_force_
	url := repo.addr.url_http_with_branch_get()
	// println(' - check repo:$url, pull:$pull_soft, reset:$reset_force')
	// println(repo.addr)
	if repo.state != GitStatus.ok || pull_soft {
		// need to get the status of the repo
		// println(' - repo $repo.addr.name check')

		mut needs_to_be_ssh := false

		// check if there is a custom key to be used (sshkey)
		needs_to_be_ssh0 := repo.ssh_key_load_if_exists() ?
		if needs_to_be_ssh0 {
			needs_to_be_ssh = true
		}

		// first check if path does not exist yet, if not need to clone
		if !os.exists(repo.path()) {
			println(' - missing repo, pull: $url-> $repo.path()')
			if !needs_to_be_ssh && ssh_agent_loaded() {
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

			process.execute_silent(cmd) or {
				println(' GIT FAILED: $cmd')
				return error('Cannot pull repo: ${repo.path()}. Error was $err')
			}
			// println(' - GIT PULL OK')
			// can return safely, because pull did work			
			repo.state = GitStatus.ok
			return
		}

		// check the branch, see if branch on FS is same as what is required if set

		if reset_force {
			println(' - remove git changes: $repo.path()')
			repo.remove_changes() ?
		}

		// println(repo.addr)
		// print_backtrace()
		if repo.addr.branch != '' {
			mut branchname := repo.branch_get() ?
			println( " - branch detected: $branchname, branch on repo obj:'$repo.addr.branch'")
			branchname = branchname.trim('\n ')
			if branchname != repo.addr.branch {
				println(' - branch switch $branchname -> $repo.addr.branch for $url')
				repo.branch_switch(repo.addr.branch) ?
				//need to pull now
				pull_soft = true
			}
			repo.state = GitStatus.ok
			return
		}

		if pull_soft {
			repo.pull() ?
		}

		repo.state = GitStatus.ok
	}
	return
}

// pulls remote content in, will fail if there are local changes
// when using force:true it means we reset, overwrite all changes
pub fn (mut repo GitRepo) pull() ? {
	println(' - PULL: ${repo.url_get(true)}')
	if !os.exists(repo.path()) {
		repo.check(false, false) ?
	} else {
		changes := repo.changes()?
		if changes{
			return error('Cannot pull repo: ${repo.path()} because there are changes in the dir.')
		}
		cmd2 := 'cd $repo.path() && git pull'
		process.execute_silent(cmd2) or {
			println(' GIT PULL FAILED: $cmd2')
			return error('Cannot pull repo: ${repo.path()}. Error was $err')
		}
	}
}

pub fn (mut repo GitRepo) commit(msg string) ? {
	change := repo.changes() or {
		return error('cannot detect if there are changes on repo.\n$err')
	}
	if change {
		cmd := "
		cd $repo.path()
		set +e
		git add . -A
		git commit -m \"$msg\"
		echo "
		process.execute_silent(cmd) or {
			return error('Cannot commit repo: ${repo.path()}. Error was $err')
		}
	} else {
		println('     > no change')
	}
}

pub fn (mut repo GitRepo) remove_changes() ? {
	change := repo.changes() or {
		return error('cannot detect if there are changes on repo.\n$err')
	}
	if change {
		println(' - remove change $repo.path()')
		cmd := '
		cd $repo.path()
		set +e
		#checkout . -f
		git reset HEAD --hard
		git clean -fd		
		#git clean -xfd && git checkout .
		git checkout .
		echo ""
		'
		process.execute_silent(cmd) or {
			return error('Cannot commit repo: ${repo.path()}. Error was $err')
		}
	} else {
		println('     > no change  $repo.path()')
	}
}

pub fn (mut repo GitRepo) push() ? {
	cmd := 'cd $repo.path() && git push'
	process.execute_silent(cmd) or {
		return error('Cannot push repo: ${repo.path()}. Error was $err')
	}
}

pub fn (mut repo GitRepo) branch_get() ?string {
	cmd := 'cd $repo.path() && git rev-parse --abbrev-ref HEAD'
	branch := process.execute_silent(cmd) or {
		return error('Cannot get branch name from repo: ${repo.path()}. Error was $err for cmd $cmd')
	}
	return branch.trim(' \n')
}

pub fn (mut repo GitRepo) branch_switch(branchname string) ? {
	mut gitstructure := gittools.new()
	if gitstructure.multibranch {
		return error('cannot do a branch switch if we are using multibranch strategy.')
	}
	changes := repo.changes()?
	if changes{
		return error('Cannot branch switch repo: ${repo.path()} because there are changes in the dir.')
	}
	cmd := 'cd $repo.path() && git checkout $branchname'
	process.execute_silent(cmd) or {
		// println('GIT CHECKOUT FAILED: $cmd_checkout')
		return error('Cannot branch switch repo: ${repo.path()}. Error was $err \n cmd: $cmd')
	}
	// println(cmd)
	repo.pull() ?
}
