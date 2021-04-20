module gittools

import os

// check if sshkey for a repo exists in the homedir/.ssh
// we check on name, if nameof repo is same as name of key we will load
// will return true if the key did exist, which means we need to connect over ssh !!!
pub fn (mut repo GitRepo) ssh_key_load_if_exists() ?bool {
	mut key_path := '$os.home_dir()/.ssh/$repo.addr.name'
	if !os.exists(key_path) {
		key_path = '.ssh/$repo.addr.name'
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
	exists, nrkeys := ssh_agent_key_loaded(repo.addr.name)
	// println(' >>> $repo.addr.name $nrkeys, $exists')

	if (!exists) || nrkeys > 0 {
		// means we did not find the key but there were other keys loaded
		// only choice we have now is to reset and use this key
		ssh_agent_reset() ?
		ssh_agent_load(key_path) ?
		return true
	} else if exists && nrkeys == 1 {
		// means the right key was loaded
		return true
	} else {
		// did not find the key nothing to do
		return false
	}
}

// get the url for the git repo, in http or ssh format
fn (mut repo GitRepo) url_get(http bool) string {
	if http {
		return repo.addr.url_http_get()
	} else {
		return repo.addr.url_ssh_get()
	}
}

// make sure we use ssh instead of https in the config file
// will return true if it changed
// http true means we will change to http method
// http false means we will change to ssh method
fn (mut repo GitRepo) connection_change(http bool) ?bool {
	path2 := repo.path_get()
	if !os.exists(path2) {
		// nothing to do
		return false
	}

	pathconfig := os.join_path(path2, '.git', 'config')
	if !os.exists(pathconfig) {
		return error("path: '$path2' is not a git dir, missed a .git/config file. Could not change git to ssh repo.")
	}
	content := os.read_file(pathconfig) or {
		return error('Failed to load config $pathconfig for sshconfig')
	}

	mut result := []string{}
	mut line2 := ''
	mut found := false
	for line in content.split_into_lines() {
		// see if we can find the line which has the url
		pos := line.index('url =') or { 0 }
		if pos > 0 {
			url := line.split('=')[1].trim(' ')
			if url.starts_with('git') && http == false {
				// means nothing to do
				return false
			}
			if url.starts_with('http') && http {
				// means nothing to do
				return false
			}
			line2 = line[0..pos] + 'url = ' + repo.url_get(http)
			found = true
		} else {
			line2 = line
		}
		result << line2
	}

	if found {
		os.write_file(pathconfig, result.join_lines()) or {
			return error('Failed to write config $pathconfig in change to ssh')
		}
		return true
	}
	return false
}
