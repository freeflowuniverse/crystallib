module gittools

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.sshagent
import freeflowuniverse.crystallib.pathlib

[heap]
pub struct GitRepo {
	id int
mut:
	gs &GitStructure [skip; str: skip]
pub mut:
	state GitStatus
	addr  GitAddr
	path  pathlib.Path
}

pub enum GitStatus {
	unknown
	changes
	ok
	error
}

[params]
pub struct RefreshArgs {
pub mut:
	reload bool
}

// get the state from the disk
pub fn (repo GitRepo) refresh(args RefreshArgs) ! {
	ds := repo_disk_status(path: repo.path.path, reload: args.reload, reload_status: true)!

	if ds.url != repo.addr.url_original {
		return error("url on repo:'${repo.addr.url_original}' not same as url on disk: ${ds.url}")
	}

	if ds.branch != repo.addr.branch {
		return error("branch on repo:'${repo.addr.url_original}' not same as branch on disk: ${ds.url}")
		// TODO: need to implement code to deal with this situation
	}
}

pub fn (repo GitRepo) state_delete() ! {
	repo_disk_status_delete(path: repo.path.path)!
}

// relative path inside the gitstructure, pointing to the repo
pub fn (repo GitRepo) path_relative() string {
	// TODO: figure out
	return repo.path.path_relative(repo.gs.rootpath.path) or { panic('couldnt get relative path') } // TODO: check if works well
}

pub fn (repo GitRepo) changes(args RefreshArgs) !bool {
	if repo.needcommit()! {
		return true
	}
	return false
}

pub fn (repo GitRepo) needcommit(args RefreshArgs) !bool {
	check := ['untracked files', 'changes not staged for commit']
	path := repo.path.path
	ds := repo_disk_status(path: path)!
	for tocheck in check {
		if ds.status.to_lower().contains(tocheck.to_lower()) {
			return true
		}
	}
	return false
}

pub fn (repo GitRepo) needpull(args RefreshArgs) !bool {
	check := ['branch is behind']
	path := repo.path.path
	ds := repo_disk_status(path: path)!
	for tocheck in check {
		if ds.status.to_lower().contains(tocheck.to_lower()) {
			return true
		}
	}
	return false
}

pub fn (repo GitRepo) needpush(args RefreshArgs) !bool {
	check := ['to publish your local commits', 'your branch is ahead of']
	path := repo.path.path
	ds := repo_disk_status(path: path)!
	for tocheck in check {
		if ds.status.to_lower().contains(tocheck.to_lower()) {
			return true
		}
	}
	return false
}

// pulls remote content in, will reset changes
pub fn (repo GitRepo) pull_reset() ! {
	repo.remove_changes()!
	repo.pull()!
}

// pulls remote content in, will fail if there are local changes
pub fn (repo GitRepo) pull() ! {
	println('   - PULL: ${repo.url_get(true)}')
	changes := repo.changes()!
	if changes {
		return error('Cannot pull repo: ${repo.path.path} because there are changes in the dir.')
	}
	cmd2 := 'cd ${repo.path.path} && git pull'
	osal.execute_silent(cmd2) or {
		println(' GIT PULL FAILED: ${cmd2}')
		return error('Cannot pull repo: ${repo.path}. Error was ${err}')
	}
	repo.refresh()!
}

pub fn (repo GitRepo) commit(msg string) ! {
	change := repo.changes() or {
		return error('cannot detect if there are changes on repo.\n${err}')
	}
	if change {
		cmd := "
		cd ${repo.path.path}
		set +e
		git add . -A
		git commit -m \"${msg}\"
		echo "
		osal.execute_silent(cmd) or {
			return error('Cannot commit repo: ${repo.path.path}. Error was ${err}')
		}
	} else {
		println('     > no change')
	}
	repo.refresh()!
}

// remove all changes of the repo, be careful
pub fn (repo GitRepo) remove_changes() ! {
	change := repo.changes() or {
		return error('cannot detect if there are changes on repo.\n${err}')
	}
	if change {
		println(' - remove change ${repo.path.path}')
		cmd := '
		cd ${repo.path.path}
		set +e
		#checkout . -f
		git reset HEAD --hard
		git clean -fd		
		#git clean -xfd && git checkout .
		git checkout .
		echo ""
		'
		osal.execute_silent(cmd) or {
			return error('Cannot commit repo: ${repo.path.path}. Error was ${err}')
		}
	} else {
		println('     > no change  ${repo.path.path}')
	}
	repo.refresh()!
}

pub fn (repo GitRepo) push() ! {
	println('   - PUSH: ${repo.url_get(true)}')
	cmd := 'cd ${repo.path.path} && git push'
	osal.execute_silent(cmd) or {
		return error('Cannot push repo: ${repo.path.path}. Error was ${err}')
	}
	repo.refresh()!
}

pub fn (repo GitRepo) branch_get() !string {
	repo.refresh(reload: true)!
	return repo.addr.branch
}

pub fn (repo GitRepo) branch_switch(branchname string) ! {
	if repo.gs.config.multibranch {
		return error('cannot do a branch switch if we are using multibranch strategy.')
	}
	changes := repo.changes()!
	if changes {
		return error('Cannot branch switch repo: ${repo.path.path} because there are changes in the dir.')
	}
	// Fetch repo before checkout, in case a new branch added.
	repo.fetch_all()!
	cmd := 'cd ${repo.path.path} && git checkout ${branchname}'
	osal.execute_silent(cmd) or {
		// println('GIT CHECKOUT FAILED: $cmd_checkout')
		return error('Cannot branch switch repo: ${repo.path.path}. Error was ${err} \n cmd: ${cmd}')
	}
	// println(cmd)
	repo.pull()!
}

pub fn (repo GitRepo) fetch_all() ! {
	cmd := 'cd ${repo.path.path} && git fetch --all'
	osal.execute_silent(cmd) or {
		// println('GIT FETCH FAILED: $cmd_checkout')
		return error('Cannot fetch repo: ${repo.path.path}. Error was ${err} \n cmd: ${cmd}')
	}
	repo.refresh()!
}

// deletes git repository
pub fn (repo GitRepo) delete() ! {
	println('   - DELETE: ${repo.url_get(true)}')
	if !os.exists(repo.path.path) {
		return
	} else {
		cmd2 := 'cd ${repo.path.path} && git pull'
		osal.execute_silent(cmd2) or {
			println(' GIT DELETE FAILED: ${cmd2}')
			return error('Cannot delete repo: ${repo.path.path}. Error was ${err}')
		}
	}
	repo.state_delete()!
}

// check if sshkey for a repo exists in the homedir/.ssh
// we check on name, if nameof repo is same as name of key we will load
// will return true if the key did exist, which means we need to connect over ssh !!!
fn (repo GitRepo) ssh_key_load_if_exists() !bool {
	mut key_path := '${os.home_dir()}/.ssh/${repo.addr.name}'
	if !os.exists(key_path) {
		key_path = '.ssh/${repo.addr.name}'
	}
	if !os.exists(key_path) {
		// tried local path to where we are, no key as well
		return false
	}
	// exists means the key has been loaded
	// nrkeys is how many keys were loaded in sshagent in first place
	exists, nrkeys := sshagent.key_loaded(repo.addr.name)
	// println(' >>> $repo.addr.name $nrkeys, $exists')

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
