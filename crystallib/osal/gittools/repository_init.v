module gittools

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.tools.sshagent
import freeflowuniverse.crystallib.clients.redisclient

// this will clone the repo if it doesn't exist yet
fn (mut repo GitRepo) load_from_url() ! {

	// first check if path does not exist yet, if not need to clone
	if !(repo.path.exists()) {

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
	}

}



//path needs to exit, load all from disk
fn (mut repo GitRepo) load_from_path() ! {

	if !repo.path.exists(){
		return error("cannot load from path, doesn't exist for ${repo.path}")
	}

	mut redis := redisclient.core_get()!
	mut urlfromcache:=redis.get(repo.cache_key_path())!
	if urlfromcache==""{
		//we don't know it means we need to fetch if from the filesystem
		st:=repo.load()!
		redis.set(repo.cache_key_path(),st.remote_url)!
		redis.expire(repo.cache_key_path(), 3600 * 24)!
		urlfromcache=redis.get(repo.cache_key_path()) or {panic("bug")}
	}

	locator:=repo.gs.locator_new(urlfromcache)!
	repo.addr=locator.addr


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
