module gittools

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.tools.sshagent
import freeflowuniverse.crystallib.core.pathlib

[heap]
pub struct GitRepo {
	id int
mut:
	gs &GitStructure [skip; str: skip]
pub mut:

	addr  GitAddr
	path  pathlib.Path
}


pub struct GitRepoStatus{
pub mut:
	need_commit bool
	need_push bool
	need pull bool
	branch string
	remote_url string
}

fn (repo GitRepo) cache_key() {
	return 'git:cache:${repo.gs.name}__${repo.addr.cachekey()}:'
}

// load state from disk
pub fn (repo GitRepo) load() ! {
	print(" - git repo load: ${repo.cache_key()}")

	pre := 
	path := args.path
	mut redis := redisclient.core_get()!

	mut st:=GitRepoStatus{}

	cmd := 'cd ${path} && git config --get remote.origin.url'
	// println(cmd)
	st.url = osal.execute_silent(cmd) or {
		return error('Cannot get remote origin url: ${path}. Error was ${err}')
	}
	st.url = st.url.trim(' \n')

	cmd2 := 'cd ${path} && git rev-parse --abbrev-ref HEAD'
	// println(cmd2)
	st.branch = osal.execute_silent(cmd2) or {
		return error('Cannot get branch: ${path}. Error was ${err}')
	}
	st.branch = st.branch.trim(' \n')


	cmd3 := 'cd ${path} &&  git status'
	mut status_str := osal.execute_silent(cmd3) or {
		return error('Cannot get status for repo: ${path}. Error was ${err}')
	}
	status_str=status_str.to_lower()

	//check if commit is needed
	check := ['untracked files', 'changes not staged for commit','to be committed']
	for tocheck in check {
		if status_str.to_lower().contains(tocheck) {
			st.need_commit=true
		}
	}

	//check if push is needed
	check2 := ['to publish your local commits', 'your branch is ahead of']
	for tocheck in check2 {
		if status_str.to_lower().contains(tocheck) {
			st.need_push=true
		}
	}

	//check if pull is needed
	check3 := ['branch is behind']
	for tocheck in check3 {
		if status_str.to_lower().contains(tocheck) {
			st.need_pull=true
		}
	}

	jsondata:=json.encode(st)!
	redis.set(repo.cache_key(), jsondata)!
	redis.expire(repo.cache_key(), 3600 * 24)!

	println(" ok")
}

pub fn (repo GitRepo) status() GitRepoStatus! {
	mut data:=redis.get(repo.cache_key())!
	if data.len==0{
		repo.load()!
		data=redis.get(repo.cache_key())!
		if data==""{
			panic("bug, redis should not be empty now")
		}
	}
	status:=json.decode(GitRepoStatus,st)!
	return status
}

// relative path inside the gitstructure, pointing to the repo
pub fn (repo GitRepo) path_relative() string {
	// TODO: figure out
	return repo.path.path_relative(repo.gs.rootpath.path) or { panic('couldnt get relative path') } // TODO: check if works well
}

// pulls remote content in, will reset changes
pub fn (repo GitRepo) pull_reset(args_ ActionArgs) ! {
	mut args:=args_
	if args.reload{
		repo.reload()!
		args.reload=false
	}	
	repo.remove_changes()!
	repo.pull()!
}

[params]
pub struct ActionArgs{
pub mut:
	reload bool = true
	msg string //only relevant for commit
}

//commit the changes, message is needed, pull from remote, push to remote
pub fn (repo GitRepo) commit_pull_push(args_ ActionArgs) ! {
	mut args:=args_
	if args.reload{
		repo.reload()!
		args.reload=false
	}
	repo.commit(args)!
	repo.pull(args)!
	repo.push(args)!
}

// pulls remote content in, will fail if there are local changes
pub fn (repo GitRepo) pull(args_ ActionArgs) ! {
	println('   - PULL: ${repo.url_get(true)}')
	if reload{

	}
	repo.load()! //first load status again
	st := repo.status()!
	if st.need_pull {
		return error('Cannot pull repo: ${repo.path.path} because there are changes in the dir.')
	}
	cmd2 := 'cd ${repo.path.path} && git pull'
	osal.execute_silent(cmd2) or {
		println(' GIT PULL FAILED: ${cmd2}')
		return error('Cannot pull repo: ${repo.path}. Error was ${err}')
	}
	repo.load()!
}

pub fn (repo GitRepo) commit(args_ ActionArgs) ! {
	st := repo.status()!
	if st.need_commit {
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
	repo.load()!
}

// remove all changes of the repo, be careful
pub fn (repo GitRepo) remove_changes() ! {
	st := repo.status()!
	if st.need_commit {
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
		println('     > nothing to remove, no changes  ${repo.path.path}')
	}
	repo.load()!
}

pub fn (repo GitRepo) push() ! {
	println('   - PUSH: ${repo.url_get(true)}')
	st := repo.status()!
	if st.need_push {	
		cmd := 'cd ${repo.path.path} && git push'
		osal.execute_silent(cmd) or {
			return error('Cannot push repo: ${repo.path.path}. Error was ${err}')
		}
	}
	repo.load()!
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
