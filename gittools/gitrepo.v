module gittools

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.sshagent
import freeflowuniverse.crystallib.pathlib

[heap]
pub struct GitRepo {
	id int [skip]
mut:
	gs    &GitStructure [str: skip]
pub mut:
	state GitStatus
	addr GitAddr
	path pathlib.Path
}


//relative path inside the gitstructure, pointing to the repo
pub fn (mut repo GitRepo) path_relative() string {
	return repo.path.path_relative(repo.gs.path)!  //TODO: check if works well
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