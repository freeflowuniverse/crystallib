module gittools

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.develop.vscode
import freeflowuniverse.crystallib.develop.sourcetree
import json

@[heap]
pub struct GitRepo {
	id int
pub mut:
	gs   &GitStructure @[skip; str: skip]
	addr &GitAddr
	path pathlib.Path
}

pub struct GitRepoStatus {
pub mut:
	need_commit bool
	need_push   bool
	need_pull   bool
	branch      string
	remote_url  string
}

pub fn (repo GitRepo) key() string {
	return repo.addr.key()
}

fn (repo GitRepo) cache_delete() ! {
	mut c := base.context()!
	mut redis := c.redis()!
	redis.del(repo.addr.cache_key_status())!
	redis.del(repo.cache_key_path())!
}

fn (repo GitRepo) cache_key_path() string {
	return repo.addr.cache_key_path(repo.path.path)
}

pub fn (mut repo GitRepo) load() !GitRepoStatus {
	repo.path.check() // could be that path changed
	if !repo.path.exists() {
		return error("cannot load from path, doesn't exist for '${repo.path.path}'")
	}

	mut c := base.context()!
	mut redis := c.redis()!
	mut isvalid := redis.get(repo.addr.cache_key_status() + '_') or { '' }
	if isvalid != '' {
		return repo.status()!
	}
	mut st := repo_load(mut repo.addr, repo.path.path)!
	repo.status_set(st)!

	p2 := repo.addr.path()!
	if p2.path != repo.path.path {
		return error("path conflict, doesn't exist for '${p2.path}' and '${repo.path.path}'")
	}
	// console.print_header(' status:\n${st}')
	redis.set(repo.addr.cache_key_status() + '_', '1')!
	redis.expire(repo.addr.cache_key_status() + '_', 5)! // 5 seconds, to not have these double gets
	return st
}

fn (repo GitRepo) status_exists() !bool {
	mut c := base.context()!
	mut redis := c.redis()!
	mut data := redis.get(repo.addr.cache_key_status()) or { return false }
	if data.len == 0 {
		return false
	}
	return true
}

fn (mut repo GitRepo) status_set(st GitRepoStatus) ! {
	if repo.addr.provider == '' || repo.addr.account == '' || repo.addr.name == ''
		|| repo.addr.branch == '' {
		locator := repo.gs.locator_new(st.remote_url)!
		repo.addr = locator.addr
		repo.addr.branch = st.branch
		// console.print_debug(repo)
	}
}

pub fn (mut repo GitRepo) status() !GitRepoStatus {
	mut c := base.context()!
	mut redis := c.redis()!
	mut cache_key := ''
	if repo.addr.provider == '' || repo.addr.account == '' || repo.addr.name == ''
		|| repo.addr.branch == '' {
		// means we don't know the addr data yet, need to see in redis if we can find the key
		cache_key = redis.get(repo.cache_key_path())!
	} else {
		// we can calculate the key
		cache_key = repo.addr.cache_key_status()
	}
	// console.print_debug("cache_key: $cache_key")
	mut data := ''
	if cache_key.len > 0 {
		data = redis.get(cache_key)!
	}
	// console.print_debug("data: $data")
	if data.len == 0 {
		repo.load()!
		data = redis.get(repo.addr.cache_key_status())!
		if data == '' {
			panic('bug, redis should not be empty now.\n${repo.addr.cache_key_status()}')
		}
	}
	st := json.decode(GitRepoStatus, data)!
	repo.status_set(st)!
	return st
}

pub fn (mut repo GitRepo) need_pull() !bool {
	s := repo.status()!
	return s.need_pull
}

// relative path inside the gitstructure, pointing to the repo
pub fn (repo GitRepo) path_relative() string {
	return repo.path.path_relative(repo.gs.rootpath.path) or { panic('couldnt get relative path') } // TODO: check if works well
}

// pulls remote content in, will reset changes
pub fn (mut repo GitRepo) pull_reset(args_ ActionArgs) ! {
	mut args := args_
	if args.reload {
		repo.load()!
		args.reload = false
	}
	repo.remove_changes(args)!
	repo.pull(args)!
}

@[params]
pub struct ActionArgs {
pub mut:
	reload bool = true
	msg    string // only relevant for commit
}

// commit the changes, message is needed, pull from remote, push to remote
pub fn (mut repo GitRepo) commit_pull_push(args_ ActionArgs) ! {
	mut args := args_
	if args.reload {
		repo.load()!
		args.reload = false
	}
	repo.commit(args)!
	repo.pull(args)!
	repo.push(args)!
}

// commit the changes, message is needed, pull from remote
pub fn (mut repo GitRepo) commit_pull(args_ ActionArgs) ! {
	mut args := args_
	if args.reload {
		repo.load()!
		args.reload = false
	}
	repo.commit(args)!
	repo.pull(args)!
}

// pulls remote content in, will fail if there are local changes
pub fn (mut repo GitRepo) pull(args_ ActionArgs) ! {
	$if debug {
		console.print_debug('  pull: ${repo.url_get(true)}')
	}
	// repo.ssh_key_load()!
	// defer {
	// 	repo.ssh_key_forget() or { panic("bug") }
	// }

	mut args := args_
	if args.reload {
		repo.load()!
		args.reload = false
	}
	// st := repo.status()!
	// if st.need_commit {
	// 	return error('Cannot pull repo: ${repo.path.path}, a commit is needed.\n${st}')
	// }
	// pull can't see the status
	cmd2 := 'cd ${repo.path.path} && git pull'
	osal.execute_silent(cmd2) or {
		console.print_debug(' GIT PULL FAILED: ${cmd2}')
		return error('Cannot pull repo: ${repo.path}. Error was ${err}')
	}
	repo.load()!
	// repo.ssh_key_forget()!
}

pub fn (mut repo GitRepo) rev() !string {
	// $if debug {
	// 	console.print_debug('   - REV: ${repo.url_get(true)}')
	// }
	cmd2 := 'cd ${repo.path.path} && git rev-parse HEAD'
	res := osal.execute_silent(cmd2) or {
		console.print_debug(' GIT REV FAILED: ${cmd2}')
		return error('Cannot rev repo: ${repo.path}. Error was ${err}')
	}
	return res.trim_space()
}

pub fn (mut repo GitRepo) commit(args_ ActionArgs) ! {
	mut args := args_
	if args.reload {
		repo.load()!
		args.reload = false
	}
	st := repo.status()!
	if st.need_commit {
		if args.msg == '' {
			return error('Cannot commit, message is empty for ${repo}')
		}
		cmd := "
		cd ${repo.path.path}
		set +e
		git add . -A
		git commit -m \"${args.msg}\"
		echo "
		osal.execute_silent(cmd) or {
			return error('Cannot commit repo: ${repo.path.path}. Error was ${err}')
		}
	} else {
		console.print_debug('     > no change')
	}
	repo.load()!
}

// remove all changes of the repo, be careful
pub fn (mut repo GitRepo) remove_changes(args_ ActionArgs) ! {
	mut args := args_
	if args.reload {
		repo.load()!
		args.reload = false
	}
	st := repo.status()!
	if st.need_commit {
		console.print_header(' remove change ${repo.path.path}')
		cmd := '
		cd ${repo.path.path}
		rm -f .git/index
		#git fetch --all
		git reset HEAD --hard
		git clean -xfd		
		git checkout . -f
		echo ""
		'
		res := osal.exec(cmd: cmd, raise_error: false)!
		console.print_debug(cmd)
		// console.print_debug(res)
		if res.exit_code > 0 {
			console.print_header(' could not remove changes, will re-clone ${repo.path.path}')
			repo.path.delete()! // remove path, this will re-clone the full thing
			repo.load_from_url()!
		}
	}
	repo.load()!
}

pub fn (mut repo GitRepo) push(args_ ActionArgs) ! {
	mut args := args_
	if args.reload {
		repo.load()!
		args.reload = false
	}
	$if debug {
		console.print_debug('   - PUSH: ${repo.url_get(true)} on ${repo.path.path}')
	}
	// repo.ssh_key_load()!
	// defer {
	// 	repo.ssh_key_forget() or { panic(err) }
	// }
	st := repo.status()!
	if st.need_push {
		console.print_debug('    - PUSH THE CHANGES')
		cmd := 'cd ${repo.path.path} && git push'
		osal.execute_silent(cmd) or {
			return error('Cannot push repo: ${repo.path.path}. Error was ${err}')
		}
	}
	repo.load()!
	// repo.ssh_key_forget()!
}

pub fn (mut repo GitRepo) branch_switch(branchname string) ! {
	if repo.gs.config.multibranch {
		return error('cannot do a branch switch if we are using multibranch strategy.')
	}
	repo.load()!
	st := repo.status()!
	if st.need_commit || st.need_push {
		return error('Cannot branch switch repo: ${repo.path.path} because there are changes in the dir.')
	}
	// Fetch repo before checkout, in case a new branch added.
	repo.fetch_all()!
	cmd := 'cd ${repo.path.path} && git checkout ${branchname}'
	osal.execute_silent(cmd) or {
		// console.print_debug('GIT CHECKOUT FAILED: $cmd_checkout')
		return error('Cannot branch switch repo: ${repo.path.path}. Error was ${err} \n cmd: ${cmd}')
	}
	// console.print_debug(cmd)
	repo.pull(reload: true)!
}

pub fn (mut repo GitRepo) fetch_all() ! {
	// repo.ssh_key_load()!
	// defer {
	// 	repo.ssh_key_forget() or { panic(err) }
	// }
	cmd := 'cd ${repo.path.path} && git fetch --all'
	osal.execute_silent(cmd) or {
		// console.print_debug('GIT FETCH FAILED: $cmd_checkout')
		return error('Cannot fetch repo: ${repo.path.path}. Error was ${err} \n cmd: ${cmd}')
	}
	repo.load()!
	// repo.ssh_key_forget()!
}

// deletes git repository
pub fn (mut repo GitRepo) delete() ! {
	$if debug {
		console.print_debug('   - DELETE: ${repo.url_get(true)}')
	}
	if !os.exists(repo.path.path) {
		return
	} else {
		panic('implement')
	}
	repo.cache_delete()!
}

//////////////////////////KEY MGMT
//////////////////////////////////

// set the key (private ssh key)
pub fn (repo GitRepo) ssh_key_set(key string) ! {
	mut p := pathlib.get_file(path: repo.ssh_key_path(), create: true)!
	p.write(key)!
}

fn (repo GitRepo) ssh_key_path() string {
	return '${os.home_dir()}/.ssh/${repo.key()}'
}

//////////////////////////EDIT CODE MGMT
//////////////////////////////////

// open sourcetree for the git repo
pub fn (repo GitRepo) sourcetree() ! {
	sourcetree.open(path: repo.path.path)!
}

// open visual studio code for repo
pub fn (repo GitRepo) vscode() ! {
	vscode.open(path: repo.path.path)!
}

// // check if sshkey for a repo exists in the homedir/.ssh
// // we check on name, if nameof repo is same as name of key we will load
// // will return true if the key did exist, which means we need to connect over ssh !!!
// fn (repo GitRepo) ssh_key_load() !bool {
// 	key_path := repo.ssh_key_path()
// 	if !os.exists(key_path) {
// 		// tried local path to where we are, no key as well
// 		return false
// 	}
// 	// panic('implement')
// 	// exists means the key has been loaded
// 	// nrkeys is how many keys were loaded in sshagent in first place
// 	// exists, nrkeys := sshagent.key_loaded(repo.addr.name)
// 	// // console.print_debug(' >>> $repo.addr.name $nrkeys, $exists')

// 	// if (!exists) || nrkeys > 0 {
// 	// 	// means we did not find the key but there were other keys loaded
// 	// 	// only choice we have now is to reset and use this key
// 	// 	sshagent.reset()!
// 	// 	sshagent.key_load(key_path)!
// 	// 	return true
// 	// } else if exists && nrkeys == 1 {
// 	// 	// means the right key was loaded
// 	// 	return true
// 	// } else {
// 	// 	// did not find the key nothing to do
// 	// 	return false
// 	// }
// 	return true
// }

// pub fn (repo GitRepo) ssh_key_forget() ! {
// 	// sshagent.key_unload(repo.ssh_key_path())!
// }
