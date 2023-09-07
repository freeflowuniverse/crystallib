module gittools

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.sshagent
// import pathlib

// check if sshkey for a repo exists in the homedir/.ssh
// we check on name, if nameof repo is same as name of key we will load
// will return true if the key did exist, which means we need to connect over ssh !!!
fn (mut repo GitRepo) ssh_key_load_if_exists() !bool {
	mut key_path := '${os.home_dir()}/.ssh/${repo.name()}'
	if !os.exists(key_path) {
		key_path = '.ssh/${repo.name()}'
	}
	if !os.exists(key_path) {
		// tried local path to where we are, no key as well
		return false
	}

	// println(" - check keypath: $key_path")

	// println(ssh_agent_key_loaded("info_digitaltwin"))
	// panic("ss")

	// exists means the key has been loaded
	// nrkeys is how many keys were loaded in sshagent in first place
	exists, nrkeys := sshagent.key_loaded(repo.name())
	// println(' >>> $repo.name() $nrkeys, $exists')

	if (!exists) || nrkeys > 0 {
		// means we did not find the key but there were other keys loaded
		// only choice we have now is to reset and use this key
		sshagent.reset()!
		sshagent.key_load(key_path)!
		return true
	} else if exists && nrkeys == 1 {
		// means the right key was loaded
		return true
	} else {
		// did not find the key nothing to do
		return false
	}
}

fn (mut repo GitRepo) path_account_get() string {
	mut provider := ''
	addr := repo.addr()
	if addr.provider == 'github.com' {
		provider = 'github'
	} else {
		provider = addr.provider
	}
	if repo.gs.codepath() == '' {
		panic('cannot be empty')
	}
	return '${repo.gs.codepath()}/${provider}/${addr.account}'
}

pub fn (mut repo GitRepo) path_content_get() string {
	mut p := repo.path()
	if repo.addr().path == '' {
		return p
	} else {
		return '${p}/${repo.addr().path}'
	}
}

pub fn (mut repo GitRepo) path() string {
	return repo.path_get()
}

pub fn (mut repo GitRepo) path_get() string {
	if repo.path != '' {
		return repo.path
	}
	if repo.gs.config.multibranch {
		return '${repo.path_account_get()}/${repo.name()}/${repo.addr().branch}'
	} else {
		return '${repo.path_account_get()}/${repo.name()}'
	}
}

pub fn (mut repo GitRepo) path_relative() string {
	if repo.gs.config.multibranch {
		return '${repo.addr().account}/${repo.name()}/${repo.addr().branch}'
	} else {
		return '${repo.addr().account}/${repo.name()}'
	}
}

// if there are changes then will return 'true', otherwise 'false'
pub fn (mut repo GitRepo) changes() !bool {
	cmd := 'cd ${repo.path()} && git status'
	// println(cmd)
	out := osal.execute_silent(cmd) or {
		return error('Could not execute command to check git status on ${repo.path()}\ncannot execute ${cmd}')
	}
	if out.contains('Untracked files') {
		// println(1)
		return true
	} else if out.contains('Your branch is ahead of') {
		// println(2)
		return true
	} else if out.contains('Changes not staged for commit') {
		// println(3)
		return true
	} else if out.contains('nothing to commit') {
		// println(4)
		return false
	} else {
		// println(5)
		return true
	}

	return true
}

fn (mut repo GitRepo) get_clone_cmd(http bool) string {
	url := repo.url_get(http)
	mut cmd := ''

	mut light := ''
	if repo.gs.config.light {
		light = ' --depth 1 --no-single-branch'
	}

	if repo.gs.config.multibranch {
		cmd = 'mkdir -p ${repo.path_account_get()}/${repo.name()} && cd ${repo.path_account_get()}/${repo.name()} && git clone ${light} ${url} ${repo.addr().branch}'
	} else {
		cmd = 'mkdir -p ${repo.path_account_get()} && cd ${repo.path_account_get()} && git clone ${light} ${url}'
	}
	if repo.addr().branch != '' {
		cmd += ' -b ${repo.addr().branch}'
	}
	if repo.addr().depth != 0 {
		cmd += ' --depth=${repo.addr().depth}'
		//  && cd $repo.name() && git fetch
		// why was this there?
	}
	// println(" - CMD: $cmd")
	return cmd
}

// this is the main git functionality to get git repo, update, reset, ...
pub fn (mut repo GitRepo) check(pull_soft_ bool, reset_force_ bool) ! {
	mut pull_soft := pull_soft_ || reset_force_
	mut reset_force := reset_force_
	url := repo.addr().url_http_with_branch_get()
	// println(' - check repo:$url, pull:$pull_soft, reset:$reset_force')
	// println(repo.addr())
	if repo.state != GitStatus.ok || pull_soft {
		// need to get the status of the repo
		// println(' - repo $repo.name() check')

		mut needs_to_be_ssh := false

		// check if there is a custom key to be used (sshkey)
		needs_to_be_ssh0 := repo.ssh_key_load_if_exists()!
		if needs_to_be_ssh0 {
			needs_to_be_ssh = true
		}

		// first check if path does not exist yet, if not need to clone
		if !os.exists(repo.path()) {
			println(' - missing repo, pull: ${url}-> ${repo.path()}')
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
				return error('Cannot pull repo: ${repo.path()}. Error was ${err}')
			}
			// println(' - GIT PULL OK')
			// can return safely, because pull did work			
			repo.state = GitStatus.ok
			return
		}

		// check the branch, see if branch on FS is same as what is required if set

		if reset_force {
			println(' - remove git changes: ${repo.path()}')
			repo.remove_changes()!
		}

		// println(repo.addr())
		// print_backtrace()
		if repo.addr().branch != '' {
			mut branchname := repo.branch_get()!
			// println( " - branch detected: $branchname, branch on repo obj:'$repo.addr().branch'")
			branchname = branchname.trim('\n ')
			if branchname != repo.addr().branch && pull_soft {
				println(' - branch switch ${branchname} -> ${repo.addr().branch} for ${url}')
				repo.branch_switch(repo.addr().branch)!
				// need to pull now
				pull_soft = true
			}
			repo.state = GitStatus.ok
			return
		}

		if pull_soft {
			repo.pull()!
		}

		repo.state = GitStatus.ok
	}
	return
}

// return the addr info of the gitrepo				
pub fn (mut repo GitRepo) addr() GitAddr {
	if repo.addr_ == none {
		repo.addr_ = addr_get_from_path(repo.path) or { panic(err) }
	}
	return repo.addr_ or { panic(err) }
}

pub fn (mut repo GitRepo) name() string {
	if repo.name_ == '' {
		repo.name_ = repo.path.split('/').last()
		if repo.name_.len < 3 {
			panic('bug, name split for git name() in repo')
		}
	}
	return repo.name_
}

// pulls remote content in, will reset changes
pub fn (mut repo GitRepo) pull_reset() ! {
	repo.remove_changes()!
	repo.pull()!
}

// pulls remote content in, will fail if there are local changes
pub fn (mut repo GitRepo) pull() ! {
	println('   - PULL: ${repo.url_get(true)}')
	if !os.exists(repo.path()) {
		repo.check(false, false)!
	} else {
		// changes := repo.changes()!
		// if changes{
		// 	return error('Cannot pull repo: ${repo.path()} because there are changes in the dir.')
		// }
		cmd2 := 'cd ${repo.path()} && git pull'
		osal.execute_silent(cmd2) or {
			println(' GIT PULL FAILED: ${cmd2}')
			return error('Cannot pull repo: ${repo.path()}. Error was ${err}')
		}
	}
}

pub fn (mut repo GitRepo) commit(msg string) ! {
	change := repo.changes() or {
		return error('cannot detect if there are changes on repo.\n${err}')
	}
	if change {
		cmd := "
		cd ${repo.path()}
		set +e
		git add . -A
		git commit -m \"${msg}\"
		echo "
		osal.execute_silent(cmd) or {
			return error('Cannot commit repo: ${repo.path()}. Error was ${err}')
		}
	} else {
		println('     > no change')
	}
}

// remove all changes of the repo, be careful
pub fn (mut repo GitRepo) remove_changes() ! {
	change := repo.changes() or {
		return error('cannot detect if there are changes on repo.\n${err}')
	}
	if change {
		println(' - remove change ${repo.path()}')
		cmd := '
		cd ${repo.path()}
		set +e
		#checkout . -f
		git reset HEAD --hard
		git clean -fd		
		#git clean -xfd && git checkout .
		git checkout .
		echo ""
		'
		osal.execute_silent(cmd) or {
			return error('Cannot commit repo: ${repo.path()}. Error was ${err}')
		}
	} else {
		println('     > no change  ${repo.path()}')
	}
}

pub fn (mut repo GitRepo) push() ! {
	println('   - PUSH: ${repo.url_get(true)}')
	cmd := 'cd ${repo.path()} && git push'
	osal.execute_silent(cmd) or {
		return error('Cannot push repo: ${repo.path()}. Error was ${err}')
	}
}

pub fn (mut repo GitRepo) branch_get() !string {
	cmd := 'cd ${repo.path()} && git rev-parse --abbrev-ref HEAD'
	branch := osal.execute_silent(cmd) or {
		return error('Cannot get branch name from repo: ${repo.path()}. Error was ${err} for cmd ${cmd}')
	}
	return branch.trim(' \n')
}

pub fn (mut repo GitRepo) branch_switch(branchname string) ! {
	if repo.gs.config.multibranch {
		return error('cannot do a branch switch if we are using multibranch strategy.')
	}
	changes := repo.changes()!
	if changes {
		return error('Cannot branch switch repo: ${repo.path()} because there are changes in the dir.')
	}
	// Fetch repo before checkout, in case a new branch added.
	repo.fetch_all()!
	cmd := 'cd ${repo.path()} && git checkout ${branchname}'
	osal.execute_silent(cmd) or {
		// println('GIT CHECKOUT FAILED: $cmd_checkout')
		return error('Cannot branch switch repo: ${repo.path()}. Error was ${err} \n cmd: ${cmd}')
	}
	// println(cmd)
	repo.pull()!
}

pub fn (mut repo GitRepo) fetch_all() ! {
	cmd := 'cd ${repo.path()} && git fetch --all'
	osal.execute_silent(cmd) or {
		// println('GIT FETCH FAILED: $cmd_checkout')
		return error('Cannot fetch repo: ${repo.path()}. Error was ${err} \n cmd: ${cmd}')
	}
}

// deletes git repository
pub fn (mut repo GitRepo) delete() ! {
	println('   - DELETE: ${repo.url_get(true)}')
	if !os.exists(repo.path()) {
		repo.check(false, false)!
	} else {
		cmd2 := 'cd ${repo.path()} && git pull'
		osal.execute_silent(cmd2) or {
			println(' GIT DELETE FAILED: ${cmd2}')
			return error('Cannot delete repo: ${repo.path()}. Error was ${err}')
		}
	}
}
