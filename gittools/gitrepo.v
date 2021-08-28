module gittools

import os
import despiegk.crystallib.process

pub fn (repo GitRepo) path_content_get() string {
	// if repo.path != '' {
	// 	return repo.path
	// }
	// panic(repo.addr.path)
	return '$repo.path_get()/$repo.addr.path'
}

pub fn (repo GitRepo) path_get() string {
	if repo.gitstructure.multibranch {
		return '$repo.addr.path_account_get()/$repo.addr.name/$repo.addr.branch'
	} else {
		return '$repo.addr.path_account_get()/$repo.addr.name'
	}
}

// if there are changes then will return 'true', otherwise 'false'
pub fn (mut repo GitRepo) changes() ?bool {
	cmd := 'cd $repo.path_get() && git status'
	out := process.execute_silent(cmd) or {
		return error('Could not execute command to check git status on $repo.path_get()\ncannot execute $cmd')
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
	url := repo.url_get(http)
	mut cmd := ''
	if repo.gitstructure.multibranch {
		cmd = 'mkdir -p $repo.addr.path_account_get()/$repo.addr.name && cd $repo.addr.path_account_get()/$repo.addr.name && git clone $url $repo.addr.branch'
	} else {
		cmd = 'mkdir -p $repo.addr.path_account_get() && cd $repo.addr.path_account_get() && git clone $url'
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
pub fn (mut repo GitRepo) check(pull_force_ bool, reset_force_ bool) ? {
	mut pull_force := pull_force_
	mut reset_force := reset_force_

	if repo.state != GitStatus.ok || pull_force_ || reset_force_ {
		// need to get the status of the repo
		// println(' - repo $repo.addr.name check')
		// println(repo)

		mut needs_to_be_ssh := false

		// check if there is a custom key to be used (sshkey)
		needs_to_be_ssh0 := repo.ssh_key_load_if_exists() ?
		if needs_to_be_ssh0 {
			needs_to_be_ssh = true
		}

		// first check if path does not exist yet, if not need to clone
		if !os.exists(repo.path_get()) {
			// println(' - NEED TO GIT PULL: -> $repo.path_get()')
			if !needs_to_be_ssh && ssh_agent_loaded() {
				needs_to_be_ssh = true
			}
			// get the url (http or ssh)
			mut cmd := ""
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
				return error('Cannot pull repo: ${repo.path_get()}. Error was $err')
			}
			// println(' - GIT PULL OK')
			// can return safely, because pull did work			
			repo.state = GitStatus.ok
			return
		}

		// check the branch, see if branch on FS is same as what is required if set

		if reset_force {
			repo.remove_changes() ?
		}

		// println(repo.addr)
		// print_backtrace() 
		if repo.addr.branch != '' {
			mut branchname := repo.branch_get() ?
			branchname = branchname.trim('\n ')
			if branchname != repo.addr.branch {
				println(' -  branch switch $branchname -> $repo.addr.branch')
				repo.branch_switch(repo.addr.branch) ?
			}
			repo.state = GitStatus.ok
			return
		}

		if pull_force {
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
	if !os.exists(repo.path_get()) {
		repo.check(false, false) ?
	} else {
		cmd2 := 'cd $repo.path_get() && git pull'
		process.execute_silent(cmd2) or {
			println(' GIT PULL FAILED: $cmd2')
			return error('Cannot pull repo: ${repo.path_get()}. Error was $err')
		}
	}
}

pub fn (mut repo GitRepo) commit(msg string) ? {
	change := repo.changes() or {
		return error('cannot detect if there are changes on repo.\n$err')
	}
	if change {
		cmd := "
		cd $repo.path_get()
		set +e
		git add . -A
		git commit -m \"$msg\"
		echo "
		process.execute_silent(cmd) or {
			return error('Cannot commit repo: ${repo.path_get()}. Error was $err')
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
		println(' - remove change $repo.path_get()')
		cmd := '
		cd $repo.path_get()
		set +e
		#checkout . -f
		git reset HEAD --hard
		git clean -fd		
		#git clean -xfd && git checkout .
		git checkout .
		echo ""
		'
		process.execute_silent(cmd) or {
			return error('Cannot commit repo: ${repo.path_get()}. Error was $err')
		}
	} else {
		println('     > no change  $repo.path_get()')
	}
}

pub fn (mut repo GitRepo) push() ? {
	cmd := 'cd $repo.path_get() && git push'
	process.execute_silent(cmd) or {
		return error('Cannot push repo: ${repo.path_get()}. Error was $err')
	}
}

pub fn (mut repo GitRepo) branch_get() ?string {
	cmd := 'cd $repo.path_get() && git rev-parse --abbrev-ref HEAD'
	branch := process.execute_silent(cmd) or {
		return error('Cannot get branch name from repo: ${repo.path_get()}. Error was $err for cmd $cmd')
	}
	return branch.trim(' ')
}

pub fn (mut repo GitRepo) branch_switch(branchname string) ? {
	if repo.gitstructure.multibranch {
		return error('cannot do a branch switch if we are using multibranch strategy.')
	}
	cmd := 'cd $repo.path_get() && git checkout $branchname'
	process.execute_silent(cmd) or {
		// println('GIT CHECKOUT FAILED: $cmd_checkout')
		return error('Cannot pull repo: ${repo.path_get()}. Error was $err \n cmd: $cmd')
	}
	// println(cmd)
	repo.pull() ?
}
