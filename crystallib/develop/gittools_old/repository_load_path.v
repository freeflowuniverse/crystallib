module gittools

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.base
import json

pub struct GitRepoStatus {
pub mut:
	key string //the key is $coderoot:$provider:$account:$reponame
	need_commit bool
	need_push   bool
	need_pull   bool
	detached bool //means we are not on branch we can be e.g. on a tag
	local_branch      string
	local_tag         string  //if branch is set local then tag cannot be set
	local_ref   string
	remote_url  string
	remote_check int //epoch when last check was
	remote_check_period int //seconds we will wait between checks , default on 0, means we check every time
	remote_branches        map[string]string // branch_name -> commit_hash (ref)
	remote_tags            map[string]string // tag_name -> commit_hash
}

//load the info from disk & remote, make sure the status is kept in memory and in redis
// 
// the key unique identifies a repo, $coderoot is an internal unique id to identify the tree of code where we checkout all git repo's
// we checkout each git repo as follows:  $coderoot/$provider/$account/$reponame
// the provider is e.g. github.com  which is the location without http(s) or git()... of where the repo's are hosted, the address of the git repo's
// above approach gives us a unique way how to locate and identify and work with git repo's
fn (mut repo GitRepo) load() ! {

	//TODO: load the GitRepoStatus from redis and stor in repo.status


	gsconfig   &GitStructureConfig
	provider   string
	account    string
	name       string // is the name of the repository	

	cache_key := repo.gs.cache_key()

	repo.status = 

	mut st:=repo.status

	path := repo.path.path //this is the path where the repo is stored

	// Get the remote URL
	cmd := 'cd ${path} && git config --get remote.origin.url'
	st.remote_url = osal.execute_silent(cmd) or {
		return error('Cannot get remote origin url: ${path}. Error was ${err}')
	}
	st.remote_url = st.remote_url.trim(' \n')

	if st.remote_url == '' {
		return error('cannot fetch info from ${path}, url not specified')
	}

	// Detect if the head is detached
	cmd_head := 'cd ${path} && git rev-parse --symbolic-full-name HEAD'
	head_status := osal.execute_silent(cmd_head) or {
		return error('Cannot check head status: ${path}. Error was ${err}')
	}
	head_status = head_status.trim(' \n')

	// Check if it's a detached head
	if head_status == 'HEAD' {
		// Try to get the tag if available
		cmd_tag := 'cd ${path} && git describe --tags --exact-match'
		st.tag = osal.execute_silent(cmd_tag) or {
			st.tag = '' // no tag found, so we keep it empty
		}
	} else {
		// If not detached, get the branch name
		cmd_branch := 'cd ${path} && git rev-parse --abbrev-ref HEAD'
		st.branch = osal.execute_silent(cmd_branch) or {
			return error('Cannot get branch: ${path}. Error was ${err}')
		}
		st.branch = st.branch.trim(' \n')
	}

	// Get local ref
	cmd_local_ref := 'cd ${path} && git rev-parse HEAD'
	st.local_ref = osal.execute_silent(cmd_local_ref) or {
		return error('Cannot get local ref: ${path}. Error was ${err}')
	}
	st.local_ref = st.local_ref.trim(' \n')

	// Get remote ref
	cmd_remote_ref := 'cd ${path} && git rev-parse @{u}'
	st.remote_ref = osal.execute_silent(cmd_remote_ref) or {
		st.remote_ref = '' // no upstream set, so we keep it empty
	}

	// Get the git status
	cmd_status := 'cd ${path} && git status'
	mut status_str := osal.execute_silent(cmd_status) or {
		return error('Cannot get status for repo: ${path}. Error was ${err}')
	}
	status_str = status_str.to_lower()

	// Check if commit is needed
	check := ['untracked files', 'changes not staged for commit', 'to be committed']
	for tocheck in check {
		if status_str.contains(tocheck) {
			st.need_commit = true
			break
		}
	}

	// Check if push is needed
	check2 := ['to publish your local commits', 'your branch is ahead of']
	for tocheck in check2 {
		if status_str.contains(tocheck) {
			st.need_push = true
			break
		}
	}

	// Check if pull is needed
	check3 := ['branch is behind']
	for tocheck in check3 {
		if status_str.contains(tocheck) {
			st.need_pull = true
			break
		}
	}

	// Save the status in Redis for caching
	locator := locator_new(addr.gsconfig, st.remote_url)!
	addr = locator.addr
	addr.branch = st.branch

	jsondata := json.encode(st)
	mut c := base.context()!
	mut redis := c.redis()!
	redis.set(addr.cache_key_status()!, jsondata)!
	redis.set(addr.cache_key_path(path), addr.cache_key_status()!)! // remember the key in redis starting from path
}
