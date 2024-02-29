module gittools

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.clients.redisclient
import json

fn repo_load(mut addr GitAddr, path string) !GitRepoStatus {
	$if debug {
		console.print_debug('load git config on fs: ${path}')
	}

	mut st := GitRepoStatus{}

	cmd := 'cd ${path} && git config --get remote.origin.url'
	// println(cmd)
	st.remote_url = osal.execute_silent(cmd) or {
		return error('Cannot get remote origin url: ${path}. Error was ${err}')
	}
	st.remote_url = st.remote_url.trim(' \n')

	if st.remote_url == '' {
		return error('cannot fetch info from ${path}, url not specified')
	}

	cmd2 := 'cd ${path} && git rev-parse --abbrev-ref HEAD'
	// println(cmd2)
	st.branch = osal.execute_silent(cmd2) or {
		return error('Cannot get branch: ${path}. Error was ${err}')
	}
	st.branch = st.branch.trim(' \n')

	if st.branch == '' {
		return error('could not find branch for.\n${cmd2}')
	}
	cmd3 := 'cd ${path} &&  git status'
	mut status_str := osal.execute_silent(cmd3) or {
		return error('Cannot get status for repo: ${path}. Error was ${err}')
	}
	status_str = status_str.to_lower()

	// check if commit is needed
	check := ['untracked files', 'changes not staged for commit', 'to be committed']
	for tocheck in check {
		if status_str.to_lower().contains(tocheck) {
			st.need_commit = true
		}
	}

	// check if push is needed
	check2 := ['to publish your local commits', 'your branch is ahead of']
	for tocheck in check2 {
		if status_str.to_lower().contains(tocheck) {
			st.need_push = true
		}
	}

	// check if pull is needed
	check3 := ['branch is behind']
	for tocheck in check3 {
		if status_str.to_lower().contains(tocheck) {
			st.need_pull = true
		}
	}

	locator := locator_new(mut addr.gsconfig, st.remote_url)!
	addr = locator.addr
	addr.branch = st.branch

	// println(st)
	// println(addr)

	$if debug {
		console.print_header(' loaded repo ${path}     --------')
	}

	jsondata := json.encode(st)
	mut redis := redisclient.core_get()!
	redis.set(addr.cache_key_status(), jsondata)!
	redis.set(addr.cache_key_path(path), addr.cache_key_status())! // remember the key in redis starting from path
	redis.expire(addr.cache_key_status(), 3600 * 24 * 7)!
	redis.expire(addr.cache_key_path(path), 3600 * 24 * 7)!
	return st
}
